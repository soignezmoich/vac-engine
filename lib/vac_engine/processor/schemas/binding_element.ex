defmodule VacEngine.Processor.BindingElement do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Meta
  alias VacEngine.Processor.Binding
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Branch
  alias VacEngine.Processor.Column
  alias VacEngine.Processor.AstType
  alias VacEngine.Processor.Variable
  alias VacEngine.Processor.Expression
  import VacEngine.EctoHelpers

  schema "bindings_elements" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:blueprint, Blueprint)
    belongs_to(:binding, Binding)
    belongs_to(:variable, Variable)

    field(:position, :integer)
    field(:index, :integer)
  end

  def changeset(data, attrs, ctx, opts \\ []) do
    data
    |> cast(attrs, [:position, :index, :variable_id])
    |> change(blueprint_id: ctx.blueprint_id, workspace_id: ctx.workspace_id)
    |> validate_required([])
  end
end
