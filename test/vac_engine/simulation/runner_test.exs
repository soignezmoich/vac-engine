defmodule VacEngine.Simulation.RunnerTest do
  use VacEngine.DataCase

  alias VacEngine.Account
  alias VacEngine.Processor
  alias VacEngine.Simulation

  alias VacEngine.Simulation.Job

  setup_all do
    [
      blueprints: Fixtures.Blueprints.blueprints(),
      simulations: Fixtures.Simulations.simulations(),
      stacks: Fixtures.SimulationStacks.stacks()
    ]
  end

  test "run simulations", %{
    stacks: stacks,
    blueprints: blueprints,
    simulations: simulations
  } do
    {:ok, workspace} = Account.create_workspace(%{name: "Test workspace"})

    blueprints =
      blueprints
      |> Enum.map(fn {name, blueprint} ->
        assert {:ok, blueprint} =
                 Processor.create_blueprint(workspace, blueprint)

        {name, blueprint}
      end)
      |> Map.new()

    stacks =
      stacks
      |> Enum.map(fn stack ->
        name = stack.name
        blueprint = Map.get(blueprints, stack.blueprint)

        assert {:ok, stack} = Simulation.create_stack(blueprint, stack.stack)
        {name, stack}
      end)
      |> Map.new()

    simulations
    |> Enum.each(fn sim ->
      stack = Map.get(stacks, sim.stack)
      job = Job.new(stack)
      assert :ok = Simulation.queue_job(job)
      assert_receive {:job_finished, job}, 1000
      # TODO check job against expectation
      # IO.inspect(job)
    end)

    Simulation.Runner.flush()
  end
end
