defmodule VacEngine.Simulation.Templates do
  @moduledoc false

  import Ecto.Changeset
  import Ecto.Query
  import VacEngine.PipeHelpers

  alias Ecto.Multi
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Repo
  alias VacEngine.Simulation.Case
  alias VacEngine.Simulation.Layer
  alias VacEngine.Simulation.Stack
  alias VacEngine.Simulation.Template

  def get_cases_using_template(%Template{} = template) do
    # Take the runnable case of the stack using the template's case
    # as template. Then extract blueprint and runnable case names.

    from(tc in Case,
      join: tl in Layer,
      on: tc.id == tl.case_id,
      join: s in Stack,
      on: tl.stack_id == s.id,
      join: rl in Layer,
      on: rl.stack_id == s.id,
      join: rc in Case,
      on: rc.id == rl.case_id,
      join: b in Blueprint,
      on: s.blueprint_id == b.id,
      where: tc.id == ^template.case_id and rl.position == 1,
      select: %{
        blueprint_name: b.name,
        runnable_case_name: rc.name,
        runnable_case_id: rc.id
      }
    )
    |> Repo.all()
  end

  def create_blank_template(%Blueprint{} = blueprint, name) do
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
    |> case do
      {:ok, %{template: template}} -> {:ok, template}
      other -> other
    end
  end

  def delete_template(%Template{} = template) do
    if used_in_stacks?(template) do
      {:error, "Can't delete template: currently in use in one or more stacks."}
    else
      do_delete_template(template)
    end
  end

  def delete_template(template_id) do
    template = Repo.get(Template, template_id)
    delete_template(template)
  end

  defp used_in_stacks?(template) do
    from(l in Layer,
      join: c in Case,
      on: c.id == l.case_id,
      where: l.blueprint_id == ^template.blueprint_id,
      where: c.id == ^template.case_id
    )
    |> Repo.all()
    |> Enum.empty?()
    |> Kernel.not()
  end

  defp do_delete_template(template) do
    # The structure below (gather_orphaned_cases -> delete_template -> delete_orphaned_cases) result
    # from the following facts:
    # - Cases can only be deleted if not referenced by a template (or layer), so the template
    #   deletion must occur case deletion.
    # - The cases to delete can be retrieved more efficiently by using the template. So
    #   the orphaned cases retrieval must occur before template deletion.
    Multi.new()
    |> multi_gather_orphaned_cases(template)
    |> Multi.delete(:delete_template, template)
    |> Multi.delete_all(
      :delete_orphaned_cases,
      fn %{gather_orphaned_cases: orphaned_cases_ids} ->
        from(c in Case, where: c.id in ^orphaned_cases_ids)
      end
    )
    |> Repo.transaction()
  end

  defp multi_gather_orphaned_cases(multi, template) do
    multi
    |> Multi.run(:gather_orphaned_cases, fn repo, _ ->
      from(c in Case,
        left_join: t in Template,
        on: t.case_id == c.id and t.id != ^template.id,
        where: c.id == ^template.case_id and is_nil(t.id),
        select: c.id
      )
      |> repo.all()
      |> ok()
    end)
  end

  def fork_template_case(%Template{} = template, name) do
    Multi.new()
    |> Multi.run(:original_case, fn repo, %{} ->
      repo.get(Case, template.case_id)
      |> case do
        nil -> {:error, "template case not found"}
        kase -> {:ok, kase |> Repo.preload([:input_entries, :output_entries])}
      end
    end)
    |> Multi.insert(:new_case, fn %{original_case: original_case} ->
      ctx = %{workspace_id: original_case.workspace_id}

      Case.nested_changeset(%Case{}, Case.to_map(original_case), ctx)
      |> change(%{name: name})
    end)
    |> Multi.update(:template, fn %{new_case: new_case} ->
      template
      |> change(%{case_id: new_case.id})
    end)
    |> Multi.update_all(
      :layers,
      fn %{new_case: new_case, original_case: original_case} ->
        from(
          l in Layer,
          where:
            l.blueprint_id == ^template.blueprint_id and
              l.case_id == ^original_case.id,
          update: [set: [case_id: ^new_case.id]]
        )
      end,
      []
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{new_case: new_case}} -> {:ok, new_case}
      other -> other
    end
  end

  def get_template(template_id) do
    from(t in Template,
      where: t.id == ^template_id,
      preload: [case: :input_entries]
    )
    |> Repo.one()
  end

  def get_templates(%Blueprint{} = blueprint) do
    from(t in Template,
      where: t.blueprint_id == ^blueprint.id
    )
    |> Repo.all()
  end

  def get_template_names(%Blueprint{} = blueprint) do
    from(t in Template,
      left_join: c in Case,
      on: t.case_id == c.id,
      where: t.blueprint_id == ^blueprint.id,
      select: {t.id, c.name, c.id}
    )
    |> Repo.all()
  end

  def get_blueprints_sharing_template_case(%Template{} = template) do
    from(t in Template,
      join: c in Case,
      on: t.case_id == c.id,
      join: b in Blueprint,
      on: t.blueprint_id == b.id,
      where: t.case_id == ^template.case_id and t.id != ^template.id,
      select: %{blueprint_name: b.name, blueprint_id: b.id}
    )
    |> Repo.all()
  end
end
