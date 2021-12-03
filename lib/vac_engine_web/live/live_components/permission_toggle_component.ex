defmodule VacEngineWeb.PermissionToggleComponent do
  use VacEngineWeb, :live_component

  alias VacEngine.Account

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(readonly: false)}
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
    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       toggle_id: "toggle_#{id}",
       has: Account.has?(role, action, scope)
     )}
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
