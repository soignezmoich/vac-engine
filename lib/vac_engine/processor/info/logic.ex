defmodule VacEngine.Processor.Info.Logic do
  @moduledoc false
  alias VacEngine.Processor.Expression

  @doc false
  def logic(blueprint) do
    blueprint
    |> get_in([
      Access.key(:deductions),
      Access.all(),
      Access.key(:branches),
      Access.all(),
      Access.key(:assignments),
      Access.all()
    ])
    |> List.flatten()
    |> Enum.reduce({%{}, %{}}, fn assign, {map, hits} ->
      key = assign.target |> Enum.join(".")
      assign_logic = Map.get(map, key, %{})
      expression = Expression.describe(assign.expression)
      descs = Map.get(assign_logic, expression, [])

      hit = Map.get(hits, key, false)
      hit = not is_nil(assign.description) or hit

      descs = [assign.description | descs] |> Enum.uniq()

      assign_logic = Map.put(assign_logic, expression, descs)

      map = map |> Map.put(key, assign_logic)

      hits = hits |> Map.put(key, hit)
      {map, hits}
    end)
    |> remove_unhited
  end

  def remove_unhited({map, hits}) do
    map
    |> Enum.filter(fn {k, _v} ->
      Map.get(hits, k)
    end)
    |> Map.new()
  end
end
