defmodule VacEngineWeb.SimulationLive.SimulationEditorTestStackComponent do
  use VacEngineWeb, :live_component

  alias VacEngine.Simulation
  alias VacEngine.Simulation.Job

  @impl true
  def update(%{action: {:job_finished, job}}, socket) do
    status =
      if job.result.has_error? do
        :error
      else
        :ok
      end

    {:ok, assign(socket, status: status)}
  end

  @impl true
  def update(%{stack: stack}, socket) do
    {:ok, assign(socket, stack: stack, status: :idle) |> run_test()}
  end

  @impl true
  def handle_event("run", _, socket) do
    {:noreply, run_test(socket)}
  end

  def run_test(%{assigns: %{status: :running}} = socket), do: socket

  def run_test(%{assigns: %{stack: stack}} = socket) do
    Job.new(stack)
    |> Simulation.queue_job()

    assign(socket, status: :running)
  end
end
