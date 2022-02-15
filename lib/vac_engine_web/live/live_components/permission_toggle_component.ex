defmodule VacEngineWeb.PermissionToggleComponent do
  use VacEngineWeb, :live_component

  import VacEngine.PipeHelpers

  alias VacEngine.Account

  @impl true
  def mount(socket) do
    socket
    |> assign(readonly: false)
    |> ok()
  end

  @impl true
  def update(
        %{
          id: id,
          role: role,
          action: action,
          scope: scope
        } = assigns,
        socket
      ) do
    socket
    |> assign(assigns)
    |> assign(
      toggle_id: "toggle_#{id}",
      has: Account.has?(role, action, scope)
    )
    |> ok()
  end

  @impl true
  def handle_event(
        "toggle_permission",
        _,
        %{
          assigns: %{
            readonly: false,
            role: role,
            action: action,
            scope: scope
          }
        } = socket
      ) do
    send(self(), {:toggle_permission, role, action, scope})
    {:noreply, socket}
  end
end
