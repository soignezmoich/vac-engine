defmodule VacEngineWeb.NavLive.Index do
  use VacEngineWeb, :live_view

  on_mount(VacEngineWeb.LiveRole)
  on_mount({VacEngineWeb.LiveLocation, ~w(workspace nav)a})

  @impl true
  def handle_params(_params, _session, socket) do
    {:noreply, socket}
  end
end
