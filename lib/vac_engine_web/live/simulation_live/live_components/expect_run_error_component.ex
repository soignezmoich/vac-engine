defmodule VacEngineWeb.SimulationLive.ExpectRunErrorComponent do
  use VacEngineWeb, :live_component

  import VacEngine.PipeHelpers
  import VacEngineWeb.IconComponent

  alias VacEngine.Simulation
  alias VacEngineWeb.SimulationLive.StackEditorComponent
  alias VacEngineWeb.SimulationLive.ToggleComponent

  def update(
        %{
          causes_error: causes_error,
          runnable_case: runnable_case,
          stack: stack
        },
        socket
      ) do
    expected_result = Map.get(runnable_case, :expected_result)

    {outcome, bg_color} =
      case {expected_result, causes_error} do
        {:error, true} -> {:success, "bg-green-100"}
        {:error, false} -> {:failure, "bg-red-100"}
        {_, true} -> {:failure, "bg-red-100"}
        _ -> {:not_tested, ""}
      end

    socket
    |> assign(
      bg_color: bg_color,
      expect_error: expected_result == :error,
      outcome: outcome,
      runnable_case: runnable_case,
      stack: stack
    )
    |> ok()
  end

  def handle_event("toggle_expect_error", %{"active" => active}, socket) do
    %{stack: stack, runnable_case: runnable_case} = socket.assigns

    Simulation.set_expect_run_error(runnable_case, active == "true")

    send_update(StackEditorComponent,
      id: "stack_editor_#{stack.id}",
      action: {:refresh, :rand.uniform()}
    )

    {:noreply, socket}
  end
end
