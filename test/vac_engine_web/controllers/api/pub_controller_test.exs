defmodule VacEngineWeb.Api.PubControllerTest do
  use VacEngineWeb.ConnCase
  alias Fixtures.Blueprints
  alias Fixtures.Cases
  alias VacEngine.Pub
  alias VacEngine.Account
  alias VacEngine.Processor

  test "POST /api/p/:id/run with no api key", %{conn: conn} do
    conn = post(conn, "/api/p/3/run")

    assert json_response(conn, 401) == %{
             "error" => "unauthorized, api_key required"
           }
  end

  test "POST /api/p/:id/run with no data", %{conn: conn} do
    conn =
      conn
      |> put_req_header("authorization", "Bearer 1234")
      |> post("/api/p/3/run")

    assert json_response(conn, 400) == %{
             "error" => "portal_id and input required"
           }
  end

  setup context do
    case context do
      %{blueprint_name: blueprint_name} ->
        blueprint = Blueprints.blueprints() |> Map.get(blueprint_name)

        {:ok, workspace} = Account.create_workspace(%{name: "Test workspace"})

        {:ok, blueprint} =
          Processor.create_blueprint(
            workspace,
            blueprint
          )

        {:ok, publication} =
          Pub.publish_blueprint(
            blueprint,
            %{"name" => "Test portal"}
          )

        {:ok, role} = Account.create_role(:api)
        {:ok, _perm} = Account.grant_permission(role, :super_admin)

        {:ok, api_token} =
          Account.create_api_token(
            role,
            Map.has_key?(
              context,
              :test_key
            )
          )

        :ok = Pub.bust_cache()
        [api_token: api_token, portal_id: publication.portal_id]

      _ ->
        []
    end
  end

  @tag blueprint_name: :nested_test
  test "POST /api/p/run with data", %{
    conn: conn,
    api_token: api_token,
    portal_id: portal_id
  } do
    Cases.cases()
    |> Enum.filter(fn cs -> is_nil(Map.get(cs, :error)) end)
    |> Enum.each(fn
      %{blueprint: :nested_test} = cas ->
        data = %{input: cas.input}

        conn =
          conn
          |> put_req_header("authorization", "Bearer #{api_token.secret}")
          |> post("/api/p/#{portal_id}/run", data)

        assert json_response(conn, 200) == %{
                 "input" => cas.input |> smap(),
                 "output" => cas.output |> smap()
               }

      _ ->
        nil
    end)

    :ok = Pub.bust_cache()
  end

  @tag blueprint_name: :date_test
  @tag :test_key
  test "POST /api/p/run with data and env", %{
    conn: conn,
    api_token: api_token,
    portal_id: portal_id
  } do
    Cases.cases()
    |> Enum.filter(fn cs -> is_nil(Map.get(cs, :error)) end)
    |> Enum.each(fn
      %{blueprint: :date_test} = cas ->
        data = %{input: cas.input, env: cas.env}

        conn =
          conn
          |> put_req_header("authorization", "Bearer #{api_token.secret}")
          |> post("/api/p/#{portal_id}/run", data)

        assert json_response(conn, 200) == %{
                 "input" => cas.input |> smap(),
                 "output" => cas.output |> smap()
               }

      _ ->
        nil
    end)

    :ok = Pub.bust_cache()
  end
end
