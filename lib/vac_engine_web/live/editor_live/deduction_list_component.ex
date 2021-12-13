defmodule VacEngineWeb.EditorLive.DeductionListComponent do
  use VacEngineWeb, :live_component

  alias VacEngineWeb.EditorLive.DeductionComponent

  @impl true
  def mount(socket) do
    {:ok, assign(socket, selected_path: nil)}
  end

  @impl true
  def update(%{action: {:select_path, path}}, socket) do
    {:ok, assign(socket, selected_path: path)}
  end

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end
