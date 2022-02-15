defmodule VacEngineWeb.InlineSearchComponent do
  use VacEngineWeb, :live_component

  import VacEngine.PipeHelpers

  @impl true
  def mount(socket) do
    socket
    |> assign(
      placholder: "type query",
      button_label: "Search",
      label: "Search",
      search_visible: false
    )
    |> ok()
  end

  @impl true
  def handle_event(
        "toggle_search",
        _,
        %{assigns: %{search_visible: vis}} = socket
      ) do
    socket
    |> assign(search_visible: !vis)
    |> noreply()
  end
end
