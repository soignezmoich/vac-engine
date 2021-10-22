defmodule VacEngineWeb.WorkspacePlug do
  import Plug.Conn

  alias VacEngine.Account

  def fetch_workspaces(%{assigns: %{role: role}} = conn, _) do
    workspaces = Account.available_workspaces(role)

    conn
    |> assign(:workspaces, workspaces)
  end

  def fetch_workspaces(conn, _), do: conn

  def fetch_current_workspace(
        %{
          assigns: %{role: _role, worksapces: workspaces},
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
