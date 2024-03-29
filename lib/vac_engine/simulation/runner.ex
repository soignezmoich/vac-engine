defmodule VacEngine.Simulation.Runner do
  @moduledoc false

  use GenServer

  import VacEngine.EnumHelpers
  import VacEngine.PipeHelpers

  alias Phoenix.PubSub
  alias VacEngine.SimulationHelpers
  alias VacEngine.Simulation
  alias VacEngine.Simulation.Setting
  alias VacEngine.Simulation.Case
  alias VacEngine.Simulation.Layer
  alias VacEngine.Simulation.Runner
  alias VacEngine.Simulation.Result
  alias VacEngine.Processor

  require Logger

  defstruct processors: %{}, job_queue: nil

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def queue(job) do
    GenServer.call(__MODULE__, {:queue, job})
  end

  def flush() do
    GenServer.call(__MODULE__, :flush)
  end

  @impl true
  def init(_opts) do
    send(self(), :dequeue)
    send(self(), :purge_cache)
    {:ok, %Runner{job_queue: []}}
  end

  @impl true
  def handle_call({:queue, job}, _from, runner) do
    queue = [job | runner.job_queue]

    Process.send_after(self(), :dequeue, 200)

    {:reply, :ok, %{runner | job_queue: queue}}
  end

  @impl true
  def handle_call(:flush, _from, runner) do
    runner.processors
    |> Enum.each(fn {_, {_ver, proc, _time}} ->
      Processor.flush_processor(proc)
    end)

    {:reply, :ok, %{runner | processors: %{}}}
  end

  @impl true
  def handle_info(:dequeue, %{job_queue: []} = runner) do
    {:noreply, runner}
  end

  @impl true
  def handle_info(:dequeue, runner) do
    runner.job_queue
    |> Enum.reduce(%{runner | job_queue: []}, fn job, runner ->
      run_job(job, runner)
    end)
    |> noreply()
  end

  @impl true
  def handle_info(:purge_cache, runner) do
    Process.send_after(self(), :purge_cache, 60_000)

    runner.processors
    |> Enum.reject(fn {_blueprint_id, {_ver, proc, time}} ->
      if Timex.diff(Timex.now(), time, :minutes) > 10 do
        Processor.flush_processor(proc)
        true
      else
        false
      end
    end)
    |> Map.new()
    |> then(fn procs ->
      %{runner | processors: procs}
    end)
    |> noreply()
  end

  defp run_job(job, runner) do
    stack =
      Simulation.get_stack!(job.stack_id, fn q ->
        q
        |> Simulation.load_stack_layers_case_entries()
        |> Simulation.load_stack_setting()
      end)

    ensure_processor_loaded(stack.blueprint_id, runner)
    |> case do
      {:ok, proc, runner} ->
        {run_stack(stack, proc), runner}

      {:error, err} ->
        {%Result{run_error: err, has_error: true}, runner}
    end
    |> then(fn {res, runner} ->
      outcome =
        if res.has_error || !res.result_match do
          :failure
        else
          :success
        end

      %{job | result: res, outcome: outcome}
      |> notify_job()

      runner
    end)
  end

  defp ensure_processor_loaded(blueprint_id, runner) do
    ver = Processor.blueprint_version(blueprint_id)

    runner.processors
    |> Map.get(blueprint_id)
    |> case do
      {^ver, proc, _} ->
        {:ok, proc,
         put_in(
           runner,
           [Access.key(:processors), blueprint_id],
           {ver, proc, Timex.now()}
         )}

      current ->
        case current do
          {_old_ver, proc, _} ->
            Processor.flush_processor(proc)

          _ ->
            nil
        end

        blueprint_id
        |> Processor.get_blueprint(fn query ->
          query
          |> Processor.load_blueprint_variables()
          |> Processor.load_blueprint_full_deductions()
        end)
        |> Processor.compile_blueprint(log: false, namespace: "Simulation")
        |> case do
          {:ok, proc} ->
            {:ok, proc,
             put_in(
               runner,
               [Access.key(:processors), blueprint_id],
               {ver, proc, Timex.now()}
             )}

          err ->
            err
        end
    end
  end

  defp notify_job(job) do
    PubSub.broadcast(VacEngine.PubSub, job.publish_on, {:job_finished, job})
  end

  defp run_stack(stack, proc) do
    {input, expected, forbid, outcome, env} = merge_stack(stack)

    Logger.disable(self())

    Processor.run(proc, input, env)
    |> tap(fn _ ->
      Logger.enable(self())
    end)
    |> case do
      {:ok, state} ->
        flat_output = flatten_map(state.output) |> Map.new()

        expected =
          expected
          |> Enum.reduce(%{}, fn {k, expected}, acc ->
            acc_item = Map.get(acc, k, %{})

            {awe, actual, match} =
              Map.fetch(flat_output, k)
              |> case do
                {:ok, val} ->
                  match = to_string(val) == expected
                  {false, val, match}

                _ ->
                  {true, nil, false}
              end

            outcome =
              case {awe, match} do
                {false, true} -> :success
                _ -> :failure
              end

            m =
              acc_item
              |> Map.merge(%{
                expected: expected,
                absent_while_expected: awe,
                actual: actual,
                match: match,
                outcome: outcome
              })

            Map.put(acc, k, m)
          end)

        forbid =
          forbid
          |> Enum.reduce(expected, fn {k, v}, acc ->
            acc_item = Map.get(acc, k, %{})

            pwf = Map.has_key?(flat_output, k)

            outcome =
              case {Map.get(acc_item, :outcome), pwf} do
                {:failure, _} -> :failure
                {_, false} -> :success
                {_, _} -> :failure
              end

            m =
              acc_item
              |> Map.merge(%{
                forbid: v,
                present_while_forbidden: pwf,
                outcome: outcome
              })

            Map.put(acc, k, m)
          end)

        entries =
          proc.blueprint.variable_path_index
          |> Enum.reduce(forbid, fn {k, v}, acc ->
            acc_item = Map.get(acc, k, %{})

            outcome =
              case Map.get(acc_item, :outcome) do
                nil -> :untested
                v -> v
              end

            m =
              acc_item
              |> Map.merge(%{
                variable_id: v.id,
                actual: Map.get(flat_output, k),
                outcome: outcome
              })

            Map.put(acc, k, m)
          end)

        has_error =
          Enum.any?(entries, fn {_k, e} ->
            match?({:ok, false}, Map.fetch(e, :match)) ||
              match?({:ok, true}, Map.fetch(e, :absent_while_expected)) ||
              match?({:ok, true}, Map.fetch(e, :present_while_forbidden))
          end)

        result_match =
          outcome.expected_result == :success ||
            not is_nil(outcome.expected_error)

        %Result{
          input: input,
          output: state.output,
          entries: entries,
          has_error: has_error,
          expected_result: outcome.expected_result,
          expected_error: outcome.expected_error,
          result_match: result_match
        }

      {:error, err} ->
        result_match =
          outcome.expected_result == :error &&
            (outcome.expected_error == nil ||
               outcome.expected_error == err)

        %Result{
          input: input,
          run_error: err,
          has_error: !result_match,
          expected_result: outcome.expected_result,
          expected_error: outcome.expected_error,
          result_match: result_match
        }
    end
  end

  defp merge_stack(stack) do
    env =
      case stack.setting do
        %Setting{env_now: now} when not is_nil(now) ->
          %{now: Timex.format!(now, "{ISO:Extended}")}

        _ ->
          %{}
      end

    stack.layers
    |> Enum.reduce(
      {%{}, %{}, %{}, %{expected_result: :success, expected_error: nil}, env},
      fn %Layer{case: kase}, {input, expected, forbid, outcome, env} ->
        l_input =
          kase.input_entries
          |> Enum.reject(fn e -> e.value == SimulationHelpers.map_value() end)
          |> Enum.map(fn e ->
            {String.split(e.key, "."), e.value}
          end)
          |> unflatten_map()

        l_expected =
          kase.output_entries
          |> Enum.reject(fn e ->
            e.forbid
          end)
          |> Enum.map(fn e ->
            {String.split(e.key, "."), e.expected}
          end)
          |> Map.new()

        l_forbid =
          kase.output_entries
          |> Enum.filter(fn e ->
            e.forbid
          end)
          |> Enum.map(fn e ->
            {String.split(e.key, "."), true}
          end)
          |> Map.new()

        cenv =
          case kase do
            %Case{env_now: now} when not is_nil(now) ->
              %{now: Timex.format!(now, "{ISO:Extended}")}

            _ ->
              %{}
          end

        outcome =
          case kase.expected_result do
            :ignore -> outcome
            r -> %{expected_result: r, expected_error: kase.expected_error}
          end

        {
          sdmerge(input, l_input),
          Map.merge(expected, l_expected),
          Map.merge(forbid, l_forbid),
          outcome,
          Map.merge(env, cenv)
        }
      end
    )
  end
end
