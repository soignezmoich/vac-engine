defmodule VacEngineWeb.LiveWorkspace do
  import Phoenix.LiveView

  def on_mount(:default, %{"workspace_id" => workspace_id}, _session, socket) do
    with {workspace_id, _} <- Integer.parse(workspace_id),
         workspace when not is_nil(workspace) <-
           Enum.find(socket.assigns.workspaces, fn w -> w.id == workspace_id end) do
      {:cont, assign(socket, workspace: workspace)}
    else
      _ ->
        raise VacEngineWeb.PermissionError
    end
  end

  def on_mount(:default, _params, _session, socket) do
    {:halt, redirect(socket, to: "/login")}
  end
end
