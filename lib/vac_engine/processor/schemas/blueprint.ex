defmodule VacEngine.Processor.Blueprint do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.EctoHelpers
  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Deduction
  alias VacEngine.Processor.Variable
  alias VacEngine.Pub.Publication
  import VacEngine.EnumHelpers

  schema "blueprints" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:parent, Blueprint)

    field(:name, :string)
    field(:description, :string)
    field(:interface_hash, :string)
    has_many(:variables, Variable, on_replace: :delete_if_exists)
    has_many(:deductions, Deduction, on_replace: :delete_if_exists)

    has_many(:publications, Publication)
    has_many(:active_publications, Publication)
    has_many(:inactive_publications, Publication)

    field(:draft, :boolean)

    field(:variable_path_index, :map, virtual: true)
    field(:variable_id_index, :map, virtual: true)
  end

  @doc false
  def changeset(data, attrs \\ %{}) do
    attrs = EctoHelpers.accept_array_or_map_for_embed(attrs, :variables)

    data
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
  end

  @doc false
  def interface_changeset(data, attrs \\ %{}) do
    data
    |> cast(attrs, [:interface_hash])
    |> validate_required([:interface_hash])
  end

  @doc false
  def variables_changeset(data, attrs, ctx) do
    attrs =
      attrs
      |> EctoHelpers.accept_array_or_map_for_embed(:variables)

    data
    |> cast(attrs, [])
    |> cast_assoc(:variables, with: {Variable, :create_changeset, [ctx]})
  end

  @doc false
  def deductions_changeset(data, attrs, ctx) do
    attrs =
      attrs
      |> EctoHelpers.set_positions(:deductions)

    data
    |> cast(attrs, [])
    |> cast_assoc(:deductions, with: {Deduction, :changeset, [ctx]})
  end

  @doc """
  Convert to map for serialization
  """
  def to_map(%Blueprint{} = b) do
    %{
      name: b.name,
      description: b.description,
      variables: Enum.map(b.variables, &Variable.to_map/1),
      deductions: Enum.map(b.deductions, &Deduction.to_map/1)
    }
    |> compact
  end
end
