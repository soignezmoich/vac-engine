defmodule VacEngine.Simulation.Templates do

  import Ecto.Changeset
  import Ecto.Query

  alias VacEngine.Repo
  alias VacEngine.Simulation.Case
  alias VacEngine.Simulation.Layer
  alias VacEngine.Simulation.Template

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

end
