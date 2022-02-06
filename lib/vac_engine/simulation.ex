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

  import Ecto.Changeset
  import Ecto.Query
  import VacEngine.EctoHelpers
  import VacEngine.EnumHelpers
  import VacEngine.PipeHelpers

  alias Ecto.Changeset
  alias Ecto.Multi
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Pub.Portal
  alias VacEngine.Repo
  alias VacEngine.Simulation.Case
  alias VacEngine.Simulation.InputEntry
  alias VacEngine.Simulation.Layer
  alias VacEngine.Simulation.OutputEntry
  alias VacEngine.Simulation.Runner
  alias VacEngine.Simulation.Stack
  alias VacEngine.Simulation.Template
  alias VacEngine.Simulation.Setting

  @runnable_layer_position 0
  @template_layer_position 1

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

  ### SIMULATION SETTINGS ###

  def get_setting(blueprint) do
    from(s in Setting,
      where: s.blueprint_id == ^blueprint.id
    )
    |> Repo.one()
  end

  def create_setting(blueprint) do
    env_now =
      Timex.parse("2000-01-01", "{YYYY}-{0M}-{0D}")
      |> case do
        {:ok, r} -> Timex.to_datetime(r)
        _ -> nil
      end

    %Setting{
      workspace_id: blueprint.workspace_id,
      blueprint_id: blueprint.id,
      env_now: env_now
    }
    |> change(%{})
    |> Repo.insert()
  end

  def update_setting(setting, env_now: env_now) do
    setting
    |> cast(%{"env_now" => env_now}, [:env_now])
    |> validate_setting()
    |> Repo.update()
  end

  def validate_setting(%Changeset{} = changeset) do
    changeset
    |> validate_required([:env_now])
    |> validate_type(:env_now, :datetime)
  end

  ### TEMPLATES ###

  def get_template(template_id) do
    from(t in Template,
      where: t.id == ^template_id,
      preload: [case: :input_entries]
    )
    |> Repo.one()
  end

  def get_templates(blueprint) do
    from(c in Case,
      join: t in Template,
      on: t.case_id == c.id,
      where: t.blueprint_id == ^blueprint.id,
      preload: [:input_entries]
    )
    |> Repo.all()
  end

  def get_template_names(blueprint) do
    from(t in Template,
      left_join: c in Case,
      on: t.case_id == c.id,
      where: t.blueprint_id == ^blueprint.id,
      select: {t.id, c.name, c.id}
    )
    |> Repo.all()
  end

  def create_blank_template(blueprint, name) do
    Multi.new()
    |> Multi.insert(:case, fn _ ->
      %Case{
        workspace_id: blueprint.workspace_id,
        name: name,
        runnable: false
      }
      |> change(%{})
      |> check_constraint(:name, name: :simulation_cases_name_format)
      |> unique_constraint([:name, :workspace_id])
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

  def delete_template(template_id) do
    template = Repo.get(Template, template_id)

    related_blueprint_layers =
      from(l in Layer,
        join: c in Case,
        on: c.id == l.case_id,
        where: l.blueprint_id == ^template.blueprint_id,
        where: c.id == ^template.case_id
      )
      |> Repo.all()

    if Enum.empty?(related_blueprint_layers) do
      Repo.delete(template)
    else
      {:error, "Can't delete template: currently in use."}
    end
  end

  ### INPUT ENTRIES ###

  def create_input_entry(kase, key, value \\ "-") do
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

  def validate_input_entry(%Changeset{} = changeset, variable) do
    changeset
    |> validate_required([:key, :value])
    |> validate_type(:value, variable.type)
    |> validate_in_enum(:value, Map.get(variable, :variable_enum))
  end

  ### OUTPUT ENTRIES ###

  def create_blank_output_entry(kase, key, variable) do
    expected = variable_default_value(variable.type, variable.enum)

    %OutputEntry{
      case_id: kase.id,
      key: key,
      expected: expected,
      workspace_id: kase.workspace_id
    }
    |> change(%{})
    |> unique_constraint([:case_id, :key])
    |> Repo.insert()
  end

  def delete_output_entry(output_entry) do
    Repo.delete(output_entry)
  end

  def set_expected(%OutputEntry{} = entry, expected) do
    entry
    |> cast(%{expected: expected, forbid: false}, [:expected, :forbid])
    |> Repo.update()
  end

  def toggle_forbidden(%OutputEntry{} = entry, forbidden) do
    entry
    |> change(%{forbid: forbidden})
    |> Repo.update()
  end

  ### CASE STACKS ###

  def delete_stack(stack_id) do
    stack = Repo.get(Stack, stack_id)
    Repo.delete(stack)
  end

  def get_stack(stack_id) do
    from(s in Stack,
      where: s.id == ^stack_id,
      preload: [layers: [case: [:input_entries, :output_entries]]]
    )
    |> Repo.one()
  end

  def get_stacks(blueprint) do
    from(s in Stack,
      where: s.blueprint_id == ^blueprint.id,
      preload: [:layers]
    )
    |> Repo.all()
  end

  def get_stack_names(blueprint) do
    from(s in Stack,
      left_join: l in Layer,
      on: l.stack_id == s.id and l.position == 0,
      left_join: c in Case,
      on: l.case_id == c.id,
      where: s.blueprint_id == ^blueprint.id,
      select: {s.id, c.name}
    )
    |> Repo.all()
  end

  def create_blank_stack(blueprint, name) do
    Multi.new()
    |> Multi.insert(:case, fn _ ->
      %Case{
        workspace_id: blueprint.workspace_id,
        name: name,
        runnable: false
      }
      |> change(%{})
      |> check_constraint(:name, name: :simulation_cases_name_format)
      |> unique_constraint([:name, :workspace_id])
    end)
    |> Multi.insert(:stack, fn _ ->
      %Stack{
        workspace_id: blueprint.workspace_id,
        blueprint_id: blueprint.id
      }
    end)
    |> Multi.insert(:layer, fn %{case: kase, stack: stack} ->
      %Layer{
        workspace_id: blueprint.workspace_id,
        blueprint_id: blueprint.id,
        case_id: kase.id,
        stack_id: stack.id,
        position: 0
      }
    end)
    |> Repo.transaction()
  end

  ### TWO-LAYERS STACKS ###

  def get_stack_template_case(%Stack{} = stack) do
    stack.layers
    |> Enum.find(&(&1.position == @template_layer_position))
    |> case do
      nil -> nil
      layer -> layer |> Map.get(:case)
    end
  end

  def get_stack_runnable_case(%Stack{} = stack) do
    stack.layers
    |> Enum.find(&(&1.position == @runnable_layer_position))
    |> Map.get(:case)
  end

  def set_stack_template(stack, template_case_id) do
    # delete previous layer relation first
    layer =
      stack.layers
      |> Enum.find(&(&1.position == @template_layer_position))

    case layer do
      nil ->
        %Layer{
          workspace_id: stack.workspace_id,
          blueprint_id: stack.blueprint_id,
          case_id: template_case_id,
          stack_id: stack.id,
          position: 1
        }
        |> Repo.insert()

      old_layer ->
        Multi.new()
        |> Multi.delete(:delete_old_layer, old_layer)
        |> Multi.insert(
          :new_layer,
          %Layer{
            workspace_id: stack.workspace_id,
            blueprint_id: stack.blueprint_id,
            case_id: template_case_id,
            stack_id: stack.id,
            position: 1
          }
        )
        |> Repo.transaction()
    end

    # create a new layer with the chosen template
  end

  def delete_stack_template(stack) do
    layer =
      stack.layers
      |> Enum.find(&(&1.position == @template_layer_position))

    Repo.delete(layer)
  end

  def variable_default_value(type, enum) do
    case {type, enum} do
      {:boolean, _} -> "false"
      {:string, nil} -> "<enter value>"
      {:string, enum} -> enum |> List.first() || ""
      {:date, _} -> "2000-01-01"
      {:datetime, _} -> "2000-01-01T00:00:00"
      {:number, _} -> "0.0"
      {:integer, _} -> "0"
      {:map, _} -> "<map>"
    end
  end
end
