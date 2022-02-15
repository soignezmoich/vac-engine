defmodule VacEngineWeb.EditorLive.DeductionListComponent do
  use VacEngineWeb, :live_component

  import VacEngine.PipeHelpers

  alias VacEngineWeb.EditorLive.DeductionComponent

  @impl true
  def mount(socket) do
    socket
    |> assign(selection: nil)
    |> ok()
  end

  @impl true
  def update(%{action: {:select, selection}}, socket) do
    socket
    |> assign(selection: selection)
    |> ok()
  end

  @impl true
  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> ok()
  end
end
