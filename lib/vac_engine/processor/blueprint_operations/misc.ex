defmodule VacEngine.Processor.Blueprints.Misc do
  @moduledoc false

  import Ecto.Query
  import VacEngine.PipeHelpers

  alias VacEngine.Repo
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprints.Load
  alias VacEngine.Processor.Blueprints.Save
  alias VacEngine.Pub.Publication

  def duplicate_blueprint(blueprint) do
    workspace = Repo.get(Workspace, blueprint.workspace_id)

    new_blueprint =
      Load.get_full_blueprint!(blueprint.id, false)
      |> Load.serialize_blueprint()
      |> func_inspect(& &1.templates, "###### TEMPLATES ######")
      |> func_inspect(& &1.stacks, "###### STACKS ######")
      |> duplicate_from_serialized!(workspace)

    {:ok, new_blueprint}
  end

  defp duplicate_from_serialized!(%{} = serialized_blueprint, workspace) do
    {:ok, new_blueprint} =
      Save.create_blueprint(workspace, serialized_blueprint)

    {:ok, renamed_blueprint} =
      Save.update_blueprint(new_blueprint, %{
        "name" => "copy of #{serialized_blueprint.name}"
      })

    renamed_blueprint
  end

  def blueprint_readonly?(%Blueprint{publications: []}), do: false

  def blueprint_readonly?(%Blueprint{publications: publications})
      when is_list(publications),
      do: true

  def blueprint_readonly?(blueprint) do
    from(p in Publication,
      where: p.blueprint_id == ^blueprint.id,
      limit: 1
    )
    |> Repo.exists?()
  end
end
