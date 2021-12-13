defmodule VacEngineWeb.EditorLive.DeductionMacros do
  defmacro handle_select_event do
    alias VacEngineWeb.EditorLive.DeductionListComponent
    alias VacEngineWeb.EditorLive.DeductionInspectorComponent

    quote do
      @impl true
      def handle_event(
            "select",
            _,
            %{assigns: %{path: path}} = socket
          ) do
        send_update(DeductionListComponent,
          id: "deduction_list",
          action: {:select_path, path}
        )

        send_update(DeductionInspectorComponent,
          id: "deduction_inspector",
          action: {:select_path, path}
        )

        {:noreply, socket}
      end
    end
  end
end
