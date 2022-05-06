defmodule VacEngineWeb.WorkspacePlug do
  @moduledoc false

  import Plug.Conn

  alias VacEngine.Account
  alias VacEngine.Query

  def fetch_workspaces(%{assigns: %{role: role}} = conn, _) do
    workspaces =
      Account.list_workspaces(fn query ->
        query
        |> Account.filter_accessible_workspaces(role)
        |> Query.order_by(:name)
      end)

    conn
    |> assign(:workspaces, workspaces)
  end

  def fetch_workspaces(conn, _), do: conn

  def fetch_current_workspace(
        %{
          assigns: %{role: _role, workspaces: workspaces},
          params: %{"workspace_id" => workspace_id}
        } = conn,
        _
      ) do
    with {workspace_id, _} <- Integer.parse(workspace_id),
         workspace when not is_nil(workspace) <-
           Enum.find(workspaces, fn w -> w.id == workspace_id end) do
      conn
      |> assign(:workspaces, workspaces)
    else
      _ ->
        raise Phoenix.NotAcceptableError
    end
  end

  def fetch_current_workspace(conn, _), do: conn
end
