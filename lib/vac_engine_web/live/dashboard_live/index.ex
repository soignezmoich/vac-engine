defmodule VacEngineWeb.DashboardLive.Index do
  use VacEngineWeb, :live_view

  on_mount(VacEngineWeb.LiveRole)
  on_mount(VacEngineWeb.LiveWorkspace)
  on_mount({VacEngineWeb.LiveLocation, ~w(workspace dashboard)a})

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _session, socket) do
    {:noreply, socket}
  end
end
