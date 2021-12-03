defmodule VacEngineWeb.LiveLocation do
  import Phoenix.LiveView

  def on_mount(location, _params, _session, socket) do
    {:cont, assign(socket, location: location)}
  end
end
