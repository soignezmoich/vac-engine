defmodule VacEngine.Processor.Blueprint do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Blueprint.Function
  alias VacEngine.Processor.Blueprint.Variable
  alias VacEngine.Processor.Blueprint.NameType

  schema "blueprints" do
    field(:name, NameType)
    field(:description, :string)
    field(:editor_data, :map)
    embeds_many(:variables, Variable)
    embeds_many(:functions, Function)

    belongs_to(:parent, Blueprint)
    field(:draft, :boolean)
  end

  def changeset(data, attrs) do
    attrs = accept_array_or_map_for_embed(attrs, :variables)

    data
    |> cast(attrs, [:name, :editor_data, :description])
    |> cast_embed(:variables, required: true)
    |> cast_embed(:functions, required: true)
    |> validate_required([:name])
  end

  defp accept_array_or_map_for_embed(attrs, key) do
    skey = to_string(key)

    cond do
      Map.has_key?(attrs, key) ->
        update_in(attrs, [key], &put_key_in_child/1)

      Map.has_key?(attrs, skey) ->
        update_in(attrs, [skey], &put_key_in_child/1)

      true ->
        attrs
    end
  end

  defp put_key_in_child(vars) when is_map(vars) do
    vars
    |> Enum.map(fn {key, attrs} ->
      if is_atom(key) do
        Map.put(attrs, :name, key)
      else
        Map.put(attrs, "name", key)
      end
    end)
  end

  defp put_key_in_child(vars), do: vars
end
