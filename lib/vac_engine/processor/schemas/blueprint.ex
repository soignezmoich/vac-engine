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
  alias VacEngine.Simulation.Setting
  alias VacEngine.Simulation.Stack
  alias VacEngine.Simulation.Template

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

    has_one(:simulation_setting, VacEngine.Simulation.Setting)
    has_many(:stacks, VacEngine.Simulation.Stack)
    has_many(:templates, VacEngine.Simulation.Template)

    field(:draft, :boolean)

    field(:variable_path_index, :map, virtual: true)
    field(:variable_id_index, :map, virtual: true)
    field(:input_variables, :any, virtual: true)
    field(:intermediate_variables, :any, virtual: true)
    field(:output_variables, :any, virtual: true)
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
    |> cast_assoc(:deductions, with: {Deduction, :nested_changeset, [ctx]})
  end

  @doc """
  Changeset to update the simulation related data.

  If the cases are provided in stack layers and templates, they will be rebuilt from
  scratch. Otherwise, ids will be matched with the existing cases.
  """
  def simulation_changeset(data, attrs, ctx) do
    data
    |> cast(attrs, [])
    |> cast_assoc(:simulation_setting, with: {Setting, :inject_changeset, [ctx]})
    |> cast_assoc(:templates, with: {Template, :nested_changeset, [ctx]})
    |> cast_assoc(:stacks, with: {Stack, :nested_changeset, [ctx]})
  end

  # def simulation_stacks_changeset(data, attrs)

  @doc """
  Convert to map for serialization
  """
  def to_map(%Blueprint{} = b) do
    simulation_setting =
      case b.simulation_setting do
        nil -> nil
        simulation_setting -> Setting.to_map(simulation_setting)
      end

    stacks =
      case b.stacks do
        nil ->
          nil

        stack_list when is_list(stack_list) ->
          Enum.map(stack_list, &Stack.to_map/1)
      end

    templates =
      case b.templates do
        nil ->
          nil

        template_list when is_list(template_list) ->
          Enum.map(template_list, &Template.to_map/1)
      end

    %{
      name: b.name,
      description: b.description,
      variables: Enum.map(b.variables, &Variable.to_map/1),
      deductions: Enum.map(b.deductions, &Deduction.to_map/1),
      simulation_setting: simulation_setting,
      stacks: stacks,
      templates: templates
    }
    |> compact
  end
end
