defmodule VacEngineWeb.LiveLocation do
  import Phoenix.LiveView

  def on_mount(location, _params, _session, socket) do
    # live_action = Map.get(socket.assigns, :live_action)
    # location = if (live_action) do
    #     location ++ [live_action]
    # else
    #     location
    # end
    {:cont, assign(socket, location: location)}
  end
end
