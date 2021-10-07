defmodule VacEngine.Processor.Blueprint do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Hash
  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Deduction
  alias VacEngine.Processor.Variable
  alias VacEngine.Processor.NameType

  schema "blueprints" do
    timestamps(type: :utc_datetime)

    field(:name, NameType)
    field(:description, :string)
    field(:interface_hash, :string)
    field(:editor_data, :map)
    embeds_many(:variables, Variable, on_replace: :delete)
    embeds_many(:deductions, Deduction, on_replace: :delete)

    belongs_to(:workspace, Workspace)
    belongs_to(:parent, Blueprint)
    field(:draft, :boolean)
  end

  def changeset(data, attrs) do
    attrs = VacEngine.Utils.accept_array_or_map_for_embed(attrs, :variables)

    data
    |> cast(attrs, [:name, :editor_data, :description])
    |> cast_embed(:variables)
    |> cast_embed(:deductions)
    |> validate_required([:name])
    |> compute_interface_hash()
  end

  defp compute_interface_hash(changeset) do
    hash =
      get_field(changeset, :variables)
      |> map_vars()
      |> inspect()
      |> Hash.hash_string()

    put_change(changeset, :interface_hash, hash)
  end

  defp map_vars(vars) do
    vars
    |> Enum.sort_by(& &1.name)
    |> Enum.map(fn v ->
      if v.input do
        [to_string(v.name), to_string(v.type), map_vars(v.children)]
      else
        nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end
end
