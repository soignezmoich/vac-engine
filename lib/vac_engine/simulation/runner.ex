defmodule VacEngine.Simulation.Runner do
  @moduledoc false

  use GenServer
  import VacEngine.EnumHelpers
  import VacEngine.PipeHelpers
  alias VacEngine.Simulation
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

  @impl true
  def init(_opts) do
    send(self(), :dequeue)
    send(self(), :purge_cache)
    {:ok, %Runner{job_queue: []}}
  end

  @impl true
  def handle_call({:queue, job}, _from, runner) do
    queue = [job | runner.job_queue]

    Process.send_after(self(), :dequeue, 10)

    {:reply, :ok, %{runner | job_queue: queue}}
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
    |> pair(:noreply)
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
    |> pair(:noreply)
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
        {%Result{run_error: err, has_error?: true}, runner}
    end
    |> then(fn {res, runner} ->
      %{job | result: res}
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
    send(job.from, {:job_finished, job})
  end

  defp run_stack(stack, proc) do
    {input, expect, forbid} = flatten_stack(stack)

    env =
      case stack.setting.env_now do
        nil -> %{}
        d -> %{now: Timex.format!(d, "{ISO:Extended}")}
      end

    Logger.disable(self())

    Processor.run(proc, input, env)
    |> tap(fn _ ->
      Logger.enable(self())
    end)
    |> case do
      {:ok, state} ->
        flat_output = flatten_map(state.output) |> Map.new()

        expect =
          flatten_map(expect)
          |> Enum.reduce(%{}, fn {k, expect}, acc ->
            {awe, actual, match} =
              Map.fetch(flat_output, k)
              |> case do
                {:ok, val} ->
                  match = to_string(val) == expect
                  {false, val, match}

                _ ->
                  {true, nil, false}
              end

            m =
              Map.get(acc, k, %{})
              |> Map.put(:expect, expect)
              |> Map.put(:absent_while_expected?, awe)
              |> Map.put(:actual, actual)
              |> Map.put(:match?, match)

            Map.put(acc, k, m)
          end)

        forbid =
          flatten_map(forbid)
          |> Enum.reduce(expect, fn {k, v}, acc ->
            pwf = Map.has_key?(flat_output, k)

            m =
              Map.get(acc, k, %{})
              |> Map.put(:forbid?, v)
              |> Map.put(:present_while_forbidden?, pwf)

            Map.put(acc, k, m)
          end)

        entries =
          proc.blueprint.variable_path_index
          |> Enum.reduce(forbid, fn {k, v}, acc ->
            m =
              Map.get(acc, k, %{})
              |> Map.put(:variable_id, v.id)

            Map.put(acc, k, m)
          end)

        has_error =
          Enum.reduce(entries, false, fn {_k, e}, has_error ->
            has_error ||
              match?({:ok, false}, Map.fetch(e, :match?)) ||
              match?({:ok, true}, Map.fetch(e, :absent_while_expected?)) ||
              match?({:ok, true}, Map.fetch(e, :present_while_forbidden?))
          end)

        %Result{
          input: input,
          output: state.output,
          entries: entries,
          has_error?: has_error
        }

      {:error, err} ->
        %Result{input: input, run_error: err, has_error?: true}
    end
  end

  defp flatten_stack(stack) do
    stack.layers
    |> Enum.reduce({%{}, %{}, %{}}, fn layer, {input, expect, forbid} ->
      l_input =
        layer.case.input_entries
        |> Enum.map(fn e ->
          {String.split(e.key, "."), e.value}
        end)
        |> unflatten_map()

      l_expect =
        layer.case.output_entries
        |> Enum.reject(fn e ->
          is_nil(e.expected)
        end)
        |> Enum.map(fn e ->
          {String.split(e.key, "."), e.expected}
        end)
        |> unflatten_map()

      l_forbid =
        layer.case.output_entries
        |> Enum.filter(fn e ->
          is_nil(e.expected)
        end)
        |> Enum.map(fn e ->
          {String.split(e.key, "."), true}
        end)
        |> unflatten_map()

      {sdmerge(input, l_input), sdmerge(expect, l_expect),
       sdmerge(forbid, l_forbid)}
    end)
  end
end
