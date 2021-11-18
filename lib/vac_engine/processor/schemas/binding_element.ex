defmodule VacEngine.Processor.BindingElement do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Binding
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Variable

  schema "bindings_elements" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:blueprint, Blueprint)
    belongs_to(:binding, Binding)
    belongs_to(:variable, Variable)

    field(:position, :integer)
    field(:index, :integer)
  end

  @doc false
  def changeset(data, attrs, ctx, _opts \\ []) do
    data
    |> cast(attrs, [:position, :index, :variable_id])
    |> change(blueprint_id: ctx.blueprint_id, workspace_id: ctx.workspace_id)
    |> validate_required([])
  end
end
