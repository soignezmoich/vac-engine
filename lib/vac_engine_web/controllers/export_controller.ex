defmodule VacEngineWeb.ExportController do
  use VacEngineWeb, :controller

  alias VacEngine.Processor
  import VacEngineWeb.PermissionHelpers
  action_fallback(VacEngineWeb.FallbackController)

  def blueprint(conn, %{"blueprint_id" => id}) do
    blueprint =
      Processor.get_blueprint!(id, fn query ->
        query
        |> Processor.load_blueprint_variables()
        |> Processor.load_blueprint_full_deductions()
      end)

    can!(conn, :read, blueprint)

    fname =
      URI.encode_www_form(blueprint.name |> String.replace(~r/[^A-z0-9]/, "_"))

    fname = "Blueprint-#{blueprint.id}-#{fname}"

    conn
    |> put_resp_header(
      "content-disposition",
      ~s[attachment; filename="#{fname}.json"]
    )
    |> json(Processor.serialize_blueprint(blueprint))
  end
end
