defmodule VacEngine.Processor.Blueprints.VariableIndex do
  @moduledoc false

  alias VacEngine.Processor.Variable

  def index_variables(variables) do
    by_parent_ids =
      variables
      |> flatten_variables()
      |> Enum.reduce(%{}, fn v, map ->
        vars = Map.get(map, v.parent_id, [])

        Map.put(map, v.parent_id, [v | vars])
      end)

    index_variables(nil, [], by_parent_ids, %{}, false)
  end

  def index_variables(parent_id, path, by_parent_ids, index, in_list) do
    {vars, index} =
      Map.get(by_parent_ids, parent_id)
      |> case do
        nil ->
          {[], index}

        vars ->
          vars
          |> Enum.map_reduce(index, fn v, index ->
            index_variable(v, path, by_parent_ids, index, in_list)
          end)
      end

    vars =
      vars
      |> Enum.sort_by(&{&1.mapping, Variable.container?(&1), &1.name})

    {vars, index}
  end

  def index_variable(var, path, by_parent_ids, index, in_list) do
    path = path ++ [var.name]

    in_list = in_list || Variable.list?(var)

    {children, index} =
      index_variables(var.id, path, by_parent_ids, index, in_list)

    var = %{var | children: children, path: path, in_list: in_list}
    {var, Map.put(index, path, var)}
  end

  defp flatten_variables(vars) when not is_list(vars), do: []

  defp flatten_variables(vars) do
    (vars ++ Enum.map(vars, fn var -> flatten_variables(var.children) end))
    |> List.flatten()
  end
end
