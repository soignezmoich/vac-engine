defmodule VacEngine.Simulation.BulkImportation do
  @moduledoc false

  # Temporary code
  # Override all cases
  import Ecto.Query
  import VacEngine.EnumHelpers
  import VacEngine.PipeHelpers

  alias VacEngine.Pub.Portal
  alias VacEngine.Repo
  alias VacEngine.Simulation.Case
  alias VacEngine.Simulation.InputEntry
  alias VacEngine.Simulation.Layer
  alias VacEngine.Simulation.OutputEntry
  alias VacEngine.Simulation.Setting
  alias VacEngine.Simulation.Stack
  alias VacEngine.Simulation.Template

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

  defp do_import_all_cases(data) do
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

        if kase.runnable == false do
          kase_id = kase.id

          from(t in Template,
            where: t.blueprint_id == ^blueprint_id and t.case_id == ^kase_id
          )
          |> Repo.one()
          |> case do
            nil ->
              %Template{
                workspace_id: workspace_id,
                blueprint_id: blueprint_id,
                case_id: kase.id
              }
              |> Repo.insert!()

            t ->
              t
          end
        end

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
        runnable: data["runnable"],
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




end
