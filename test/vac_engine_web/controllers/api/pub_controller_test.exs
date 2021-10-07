defmodule VacEngineWeb.Api.PubControllerTest do
  use VacEngineWeb.ConnCase
  alias Fixtures.Blueprints
  alias Fixtures.Cases
  alias VacEngine.Pub
  alias VacEngine.Account
  alias VacEngine.Processor
  alias VacEngine.Processor.Blueprint

  test "POST /api/pub/run with no api key", %{conn: conn} do
    conn = post(conn, "/api/pub/run")

    assert json_response(conn, 401) == %{
             "error" => "unauthorized, api_key required"
           }
  end

  test "POST /api/pub/run with no data", %{conn: conn} do
    conn =
      conn
      |> put_req_header("authorization", "Bearer 1234")
      |> post("/api/pub/run")

    assert json_response(conn, 400) == %{
             "error" => "portal_id and input required"
           }
  end

  test "POST /api/pub/run with data", %{conn: conn} do
    blueprint = Blueprints.blueprints() |> Map.get(:ruleset0)

    {:ok, workspace} = Account.create_workspace(%{name: "Test workspace"})

    {:ok, blueprint} =
      Processor.create_blueprint(
        workspace,
        blueprint
      )

    {:ok, publication} = Pub.publish_blueprint(blueprint)

    {:ok, role} = Account.create_role(:api)
    {:ok, role} = Account.grant_permission(role, [:global, :users, :read])
    {:ok, role} = Account.grant_permission(role, [:global, :workspaces, :read])
    {:ok, api_token} = Account.create_api_token(role)

    Pub.refresh_cache()

    Cases.cases()
    |> Enum.each(fn
      %{blueprint: :ruleset0} = cas ->
        data = %{portal_id: publication.portal_id, input: cas.input}

        conn =
          conn
          |> put_req_header("authorization", "Bearer #{api_token.secret}")
          |> post("/api/pub/run", data)

        assert json_response(conn, 200) == %{
                 "input" => cas.input |> smap()
               }

      _ ->
        nil
    end)
  end
end
