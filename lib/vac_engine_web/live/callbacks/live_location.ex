defmodule VacEngineWeb.LiveLocation do
  @moduledoc false

  import Phoenix.LiveView
  import VacEngine.PipeHelpers

  def on_mount(location, _params, _session, socket) do
    socket
    |> assign(location: location)
    |> pair(:cont)
  end
end
