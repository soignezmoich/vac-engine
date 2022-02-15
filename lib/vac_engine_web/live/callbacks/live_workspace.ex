defmodule VacEngineWeb.LiveWorkspace do
  import Phoenix.LiveView
  import VacEngine.PipeHelpers

  def on_mount(:default, %{"workspace_id" => workspace_id}, _session, socket) do
    with {workspace_id, _} <- Integer.parse(workspace_id),
         workspace when not is_nil(workspace) <-
           Enum.find(socket.assigns.workspaces, fn w -> w.id == workspace_id end) do
      socket
      |> assign(workspace: workspace)
      |> pair(:cont)
    else
      _ ->
        raise VacEngineWeb.PermissionError
    end
  end

  def on_mount(:default, _params, _session, socket) do
    socket
    |> redirect(to: "/login")
    |> pair(:halt)
  end
end
