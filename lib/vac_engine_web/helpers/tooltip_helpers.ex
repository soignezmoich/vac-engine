defmodule VacEngineWeb.TooltipHelpers do
  defmacro __using__(_opts) do
    quote do
      @impl true
      def handle_info(:clear_tooltip, socket) do
        {:noreply, assign(socket, current_tooltip: nil, clear_tooltip_ref: nil)}
      end

      defp set_tooltip(socket, key) do
        ref = Process.send_after(self(), :clear_tooltip, 2000)

        socket
        |> clear_tooltip()
        |> assign(current_tooltip: key, clear_tooltip_ref: ref)
      end

      defp clear_tooltip(socket) do
        if socket.assigns.clear_tooltip_ref != nil do
          if Process.cancel_timer(socket.assigns.clear_tooltip_ref) == false do
            raise "cannot stop timer"
          end
        end

        assign(socket, current_tooltip: nil, clear_tooltip_ref: nil)
      end
    end
  end
end
