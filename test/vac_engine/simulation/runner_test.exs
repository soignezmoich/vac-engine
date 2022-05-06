defmodule VacEngine.Simulation.RunnerTest do
  @moduledoc false

  use VacEngine.DataCase

  alias VacEngine.Account
  alias VacEngine.Processor
  alias VacEngine.Simulation

  alias VacEngine.Simulation.Job

  setup_all do
    [
      blueprints: Fixtures.Blueprints.blueprints(),
      simulations: Fixtures.Simulations.simulations()
    ]
  end

  test "run simulations", %{
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

    simulations
    |> Enum.map(fn sim ->
      blueprint = Map.get(blueprints, sim.blueprint)

      assert {:ok, stack} = Simulation.create_stack(blueprint, sim.stack)
      job = Job.new(stack)
      pub = "stack.#{stack.id}"
      job = %{job | publish_on: pub}
      Phoenix.PubSub.subscribe(VacEngine.PubSub, pub)
      assert :ok = Simulation.queue_job(job)
      assert_receive {:job_finished, %Job{publish_on: ^pub} = job}, 1000

      entries = job.result.entries || %{}

      Enum.each(sim.result, fn {path, r} ->
        entry = Map.get(entries, path, %{})
        assert MapSet.subset?(MapSet.new(r), MapSet.new(entry))
      end)

      case sim do
        %{error: err} when not is_nil(err) ->
          assert job.result.run_error == err
          assert job.result.expected_error == err
          assert job.result.expected_result == :error

        _ ->
          assert job.result.expected_result == :success
          assert job.result.run_error == nil
      end
    end)

    Simulation.Runner.flush()
  end
end
