defmodule VacEngineWeb.InlineSearchComponent do
  use VacEngineWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(
       placholder: "type query",
       button_label: "Search",
       label: "Search",
       search_visible: false
     )}
  end

  @impl true
  def handle_event(
        "toggle_search",
        _,
        %{assigns: %{search_visible: vis}} = socket
      ) do
    {:noreply, assign(socket, search_visible: !vis)}
  end
end
