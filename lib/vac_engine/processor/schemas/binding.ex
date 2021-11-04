defmodule VacEngine.Processor.Binding do
  @moduledoc """
  An expression binding
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.BindingElement
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Expression
  import VacEngine.EctoHelpers

  schema "bindings" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:blueprint, Blueprint)
    belongs_to(:expression, Expression)
    has_many(:elements, BindingElement)

    field(:position, :integer)
  end

  @doc false
  def changeset(data, attrs, ctx, _opts \\ []) do
    attrs
    |> get_in_attrs(:path)
    |> Enum.reduce({[], []}, fn
      elem, {path, [{_, nil} | tail]} when is_integer(elem) ->
        {path, [{path, elem} | tail]}

      elem, {parents, list} ->
        path = parents ++ [elem]
        {path, [{path, nil} | list]}
    end)
    |> elem(1)
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce_while([], fn {{vpath, index}, position}, elements_attrs ->
      get_in(ctx, [:variable_path_index, vpath])
      |> case do
        nil ->
          {:halt, {:error, "variable not found #{vpath}"}}

        var ->
          e_attrs = %{position: position, index: index, variable_id: var.id}
          {:cont, elements_attrs ++ [e_attrs]}
      end
    end)
    |> case do
      {:error, msg} ->
        data
        |> cast(attrs, [])
        |> add_error(:elements, msg)

      elements_attrs ->
        attrs =
          attrs
          |> put_in_attrs(:elements, elements_attrs)

        data
        |> cast(attrs, [:position])
        |> change(
          blueprint_id: ctx.blueprint_id,
          workspace_id: ctx.workspace_id
        )
        |> cast_assoc(:elements, with: {BindingElement, :changeset, [ctx]})
        |> validate_required([])
    end
  end

  @doc false
  def to_path(nil, _ctx), do: nil

  def to_path(binding, %{variable_id_index: index}) do
    binding.elements
    |> Enum.reduce([], fn el, path ->
      to_path_el(el, path, index)
    end)
  end

  defp to_path_el(el, path, index) do
    get_in(index, [el.variable_id, Access.key(:name)])
    |> case do
      nil ->
        path

      name ->
        if el.index != nil do
          path ++ [name, el.index]
        else
          path ++ [name]
        end
    end
  end
end
