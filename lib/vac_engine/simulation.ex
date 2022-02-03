defmodule VacEngine.Simulation do
  @moduledoc """
  Provides the model for the blueprint simulation. Simulation is useful
  to assess whether a ruleset meets the business requirements.

  Simulation is based on *cases* that describe the expected output for a given
  input.

  The content of a case can be used as a base for another case, forming a *stack*
  (technically, even a single case is part of a stack).

  Cases are created workspace-wide whereas case stacks are limited to the blueprint
  scope. This structure allows to share cases among several blueprints.
  """

  alias VacEngine.Repo
  alias Ecto.Multi
  import VacEngine.PipeHelpers
  import VacEngine.EnumHelpers
  import Ecto.Query
  import Ecto.Changeset
  alias VacEngine.Pub.Portal
  alias VacEngine.Simulation.Runner
  alias VacEngine.Simulation.Case
  alias VacEngine.Simulation.Template
  alias VacEngine.Simulation.Stack
  alias VacEngine.Simulation.Layer
  alias VacEngine.Simulation.Setting
  alias VacEngine.Simulation.InputEntry
  alias VacEngine.Simulation.OutputEntry
  alias VacEngine.Processor.Blueprint

  def queue_job(job) do
    Runner.queue(job)
  end

  def list_cases(queries) do
    Case
    |> queries.()
    |> Repo.all()
  end

  def get_case!(case_id, queries) do
    Case
    |> queries.()
    |> Repo.get!(case_id)
  end

  def get_case(case_id, queries) do
    Case
    |> queries.()
    |> Repo.get(case_id)
  end

  def list_stacks(queries) do
    Stack
    |> queries.()
    |> Repo.all()
  end

  def get_stack!(stack_id, queries) do
    Stack
    |> queries.()
    |> Repo.get!(stack_id)
  end

  def get_stack(stack_id, queries) do
    Stack
    |> queries.()
    |> Repo.get(stack_id)
  end

  def filter_stacks_by_blueprint(query, blueprint) do
    from(b in query, where: b.blueprint_id == ^blueprint.id)
  end

  def filter_cases_by_workspace(query, workspace) do
    from(b in query, where: b.workspace_id == ^workspace.id)
  end

  def load_stack_layers(query) do
    layer_query =
      from(l in Layer,
        order_by: l.position,
        preload: :case
      )

    from(b in query, preload: [layers: ^layer_query])
  end

  def load_stack_layers_case_entries(query) do
    layer_query =
      from(l in Layer,
        order_by: l.position,
        preload: [case: [:input_entries, :output_entries]]
      )

    from(b in query, preload: [layers: ^layer_query])
  end

  def load_stack_setting(query) do
    from(b in query, preload: :setting)
  end

  def create_stack(%Blueprint{} = blueprint, attrs \\ %{}) do
    Stack.nested_changeset(
      %Stack{},
      attrs,
      %{blueprint_id: blueprint.id, workspace_id: blueprint.workspace_id}
    )
    |> Repo.insert()
  end

  # Temporary code
  # Override all cases
  def import_all_cases(path) do
    File.read(path)
    |> then_ok(fn json ->
      Jason.decode(json)
    end)
    |> then_ok(fn data ->
      Repo.transaction(fn _ ->
        do_import_all_cases(data)
      end)
      |> case do
        {:ok, _} -> :ok
        err -> err
      end
    end)
  end

  def do_import_all_cases(data) do
    Repo.query("delete from simulation_stacks;")
    Repo.query("delete from simulation_templates;")
    Repo.query("delete from simulation_cases;")

    cases =
      data["cases"]
      |> Enum.reduce(%{}, fn c, acc ->
        Map.put(acc, c["id"], c)
      end)

    data["stacks"]
    |> Enum.each(fn s ->
      portal_id = s["portal_id"]

      portal =
        from(p in Portal,
          where: p.id == ^portal_id
        )
        |> Repo.one!()

      workspace_id = portal.workspace_id
      blueprint_id = portal.blueprint_id

      stack =
        %Stack{
          workspace_id: workspace_id,
          blueprint_id: blueprint_id,
          active: true
        }
        |> Repo.insert!()

      s["layers"]
      |> Enum.reject(&is_nil/1)
      |> Enum.with_index()
      |> Enum.map(fn {layer, idx} ->
        case_id = layer

        rcase = Map.get(cases, case_id)

        kase = get_or_insert_case(rcase, workspace_id)

        env_now =
          Timex.parse(rcase["env_now"], "{YYYY}-{0M}-{0D}")
          |> case do
            {:ok, r} -> Timex.to_datetime(r)
            _ -> nil
          end

        if env_now do
          from(s in Setting,
            where:
              s.blueprint_id == ^blueprint_id and
                s.workspace_id == ^workspace_id
          )
          |> Repo.delete_all()

          %Setting{
            blueprint_id: blueprint_id,
            workspace_id: workspace_id,
            env_now: env_now
          }
          |> Repo.insert!()
        end

        %Layer{
          blueprint_id: blueprint_id,
          case_id: kase.id,
          stack_id: stack.id,
          workspace_id: workspace_id,
          position: idx
        }
        |> Repo.insert!()
      end)
    end)

    :ok
  end

  defp get_or_insert_case(data, workspace_id) do
    case_id = data["id"]

    from(c in Case,
      where:
        c.workspace_id == ^workspace_id and
          fragment(
            "? like(concat('rid: ', ?::numeric))",
            c.description,
            ^case_id
          )
    )
    |> Repo.one()
    |> case do
      nil ->
        insert_case(data, workspace_id)

      c ->
        c
    end
  end

  defp insert_case(data, workspace_id) do
    case_id = data["id"]

    env_now =
      Timex.parse(data["env_now"], "{YYYY}-{0M}-{0D}")
      |> case do
        {:ok, r} -> Timex.to_datetime(r)
        _ -> nil
      end

    kase =
      %Case{
        workspace_id: workspace_id,
        name: data["name"],
        description: "rid: #{case_id}",
        runnable: true,
        env_now: env_now
      }
      |> Repo.insert!()

    data["input"]
    |> flatten_map()
    |> Enum.each(fn {k, v} ->
      %InputEntry{
        case_id: kase.id,
        workspace_id: workspace_id,
        key: Enum.join(k, "."),
        value: to_string(v)
      }
      |> Repo.insert!()
    end)

    data["expect"]
    |> flatten_map()
    |> Enum.each(fn {k, v} ->
      %OutputEntry{
        case_id: kase.id,
        workspace_id: workspace_id,
        key: Enum.join(k, "."),
        expected: to_string(v)
      }
      |> Repo.insert!()
    end)

    data["forbid"]
    |> flatten_map()
    |> Enum.each(fn {k, _v} ->
      %OutputEntry{
        case_id: kase.id,
        workspace_id: workspace_id,
        key: Enum.join(k, "."),
        forbid: true
      }
      |> Repo.insert!()
    end)

    kase
  end

  ### TEMPLATES ###

  def get_templates(blueprint) do
    from(c in Case,
      join: t in Template,
      on: t.case_id == c.id,
      where: t.blueprint_id == ^blueprint.id,
      preload: [:input_entries]
    )
    |> Repo.all()
  end

  def create_template(blueprint, name) do
    Multi.new()
    |> Multi.insert(:case, fn _ ->
      %Case{
        workspace_id: blueprint.workspace_id,
        name: name,
        runnable: false
      }
    end)
    |> Multi.insert(:template, fn %{case: kase} ->
      %Template{
        workspace_id: blueprint.workspace_id,
        blueprint_id: blueprint.id,
        case_id: kase.id
      }
    end)
    |> Repo.transaction()
  end

  def update_template(_template, _attrs) do
  end

  def create_input_entry(kase, key, value \\ "") do
    %InputEntry{
      case_id: kase.id,
      key: key,
      value: value,
      workspace_id: kase.workspace_id
    }
    |> change(%{})
    |> unique_constraint([:case_id, :key])
    |> Repo.insert()
  end

  def delete_input_entry(input_entry) do
    Repo.delete(input_entry)
  end

  def update_input_entry(input_entry, value) do
    input_entry
    |> InputEntry.changeset(%{value: value})
    |> Repo.update()
  end

  # ### CASE STACKS ###

  # def get_stacks(workspace_id, blueprint_id) do

  # end

  ### CASE EDITION ###

  # def get_cases(workspace_id) do

  # end

  # def get_stacks(workspace_id, blueprint_id) do

  # end

  # def set_simulation_time() do

  # end

  # def get_case!() do

  # end

  # def get_stack() do

  # end

  # def create_input_entry() do

  # end

  # def set_input_entry() do

  # end

  # def create_output_entry() do

  # end

  # def set_output_entry() do

  # end

  # def set_case_time() do

  # end
end
