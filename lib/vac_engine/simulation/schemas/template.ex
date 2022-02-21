defmodule VacEngine.Simulation.Template do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Simulation.Case
  alias VacEngine.Simulation.Template

  schema "simulation_templates" do
    belongs_to(:blueprint, Blueprint)
    belongs_to(:workspace, Workspace)
    belongs_to(:case, Case)
  end

  def to_map(%Template{} = t) do
    kase =
      case t.case do
        %Case{} -> Case.to_map(t.case)
        _ -> nil
      end

    %{
      case: kase,
      case_id: t.case_id
    }
  end

  # Inject template without any case.
  # This should be used to link template with an existing case.
  def inject_changeset(template, %{case: nil, case_id: _case_id} = params, ctx) do
    bp = ctx.bp_base

    template
    |> cast(
      Map.merge(params, %{blueprint_id: bp.id, workspace_id: bp.workspace_id}),
      [:blueprint_id, :case_id, :workspace_id]
    )
  end

  # Inject template with a case.
  # Here, a new case is created and the case ID is ignored.
  def inject_changeset(template, params, ctx) do
    bp = ctx.bp_base

    template
    |> cast(
      Map.merge(params, %{blueprint_id: bp.id, workspace_id: bp.workspace_id}),
      [:case, :case_id, :blueprint_id, :workspace_id]
    )
    |> cast_assoc(:case, with: {Case, :nested_changeset, ctx})
  end
end
