defmodule VacEngine.Simulation.Template do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Repo
  alias VacEngine.Simulation.Case
  alias VacEngine.Simulation.Template

  schema "simulation_templates" do
    belongs_to(:blueprint, Blueprint)
    belongs_to(:workspace, Workspace)
    belongs_to(:case, Case)
  end

  # If the case is present, create the full case map.
  def to_map(%Template{case: %Case{} = kase}) do
    %{case: Case.to_map(kase)}
  end

  # If case is not present (preloaded), make a reference using
  # the case id.
  def to_map(%Template{case_id: case_id}) do
    %{case: %{id: case_id}}
  end

  # Inject template with a reference to an existing case (no full case).
  def nested_changeset(template, %{case: %{id: case_id}} = params, ctx) do
    referenced_case = Repo.get(Case, case_id)

    template
    |> cast(
      Map.merge(params, %{
        blueprint_id: ctx.blueprint_id,
        workspace_id: ctx.workspace_id
      }),
      [:blueprint_id, :workspace_id]
    )
    |> put_assoc(:case, referenced_case)
  end

  # Inject template with a full case description so that a new case is created.
  def nested_changeset(template, params, ctx) do
    template
    |> cast(params, [])
    |> change(blueprint_id: ctx.blueprint_id, workspace_id: ctx.workspace_id)
    |> cast_assoc(:case, with: {Case, :nested_changeset, [ctx]})
  end

end
