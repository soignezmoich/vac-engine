defmodule VacEngine.Processor.Deduction do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  import VacEngine.EctoHelpers
  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Branch
  alias VacEngine.Processor.Column
  alias VacEngine.Processor.Deduction
  import VacEngine.EnumHelpers

  schema "deductions" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:blueprint, Blueprint)

    has_many(:branches, Branch, on_replace: :delete_if_exists)
    has_many(:columns, Column, on_replace: :delete_if_exists)

    field(:position, :integer)
    field(:description, :string)
  end

  @doc false
  def changeset(data, attrs \\ %{}) do
    data
    |> cast(attrs, [:description, :position])
    |> validate_required([])
    |> prepare_changes(fn changeset ->
      blueprint_id = get_field(changeset, :blueprint_id)
      shift_position(changeset, :blueprint_id, blueprint_id)
    end)
  end

  @doc false
  def nested_changeset(data, attrs, ctx) do
    attrs =
      attrs
      |> set_positions(:branches)
      |> set_positions(:columns)

    data
    |> cast(attrs, [:description, :position])
    |> change(blueprint_id: ctx.blueprint_id, workspace_id: ctx.workspace_id)
    |> cast_assoc(:branches, with: {Branch, :nested_changeset, [ctx]})
    |> cast_assoc(:columns, with: {Column, :nested_changeset, [ctx]})
    |> validate_required([])
    |> prepare_changes(fn changeset ->
      blueprint_id = get_field(changeset, :blueprint_id)
      shift_position(changeset, :blueprint_id, blueprint_id)
    end)
  end

  @doc """
  Convert to map for serialization
  """
  def to_map(%Deduction{} = d) do
    %{
      description: d.description,
      columns: Enum.map(d.columns, &Column.to_map/1),
      branches: Enum.map(d.branches, &Branch.to_map/1)
    }
    |> compact
  end
end
