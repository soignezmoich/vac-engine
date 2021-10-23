defmodule VacEngine.Processor.Info.Logic do
  alias VacEngine.Processor.Expression

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
    |> Enum.reduce(%{}, fn assign, map ->
      key = assign.target |> Enum.join(".")
      assign_logic = Map.get(map, key, %{})
      expression = Expression.describe(assign.expression)
      descs = Map.get(assign_logic, expression, [])

      if is_nil(assign.description) do
        map
      else
        descs = [assign.description | descs] |> Enum.uniq()
        assign_logic = Map.put(assign_logic, expression, descs)
        Map.put(map, key, assign_logic)
      end
    end)
  end
end
