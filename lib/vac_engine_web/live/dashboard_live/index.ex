defmodule VacEngineWeb.DashboardLive.Index do
  use VacEngineWeb, :live_view

  on_mount(VacEngineWeb.LiveRole)
  on_mount(VacEngineWeb.LiveWorkspace)
  on_mount({VacEngineWeb.LiveLocation, ~w(workspace dashboard)a})
end
