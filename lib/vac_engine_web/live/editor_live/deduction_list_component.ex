defmodule VacEngineWeb.EditorLive.DeductionListComponent do
  use VacEngineWeb, :live_component

  alias VacEngineWeb.EditorLive.DeductionComponent

  @impl true
  def mount(socket) do
    {:ok, assign(socket, selection: nil)}
  end

  @impl true
  def update(%{action: {:select, selection}}, socket) do
    {:ok, assign(socket, selection: selection)}
  end

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end
