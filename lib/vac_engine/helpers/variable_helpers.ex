defmodule VacEngine.VariableHelpers do
  alias VacEngine.Processor.Variable

  @doc """
  Flatten the variable tree as a list containing the variable itself and all
  it's children.
  """
  def flatten_variable_tree(variable) do
    case variable do
      %{children: children} ->
        [
          variable
          | children
            |> Enum.flat_map(fn child -> flatten_variable_tree(child) end)
        ]

      _ ->
        [variable]
    end
  end

  @doc """
  Flatten all variables in a collection of variable trees as a single list.
  An optional argument can define a mapping filter.
  """
  def flatten_variables(variables, mapping \\ nil) do
    collection =
      case mapping do
        "input" ->
          variables |> Enum.filter(&Variable.input?(&1))

        "output" ->
          variables |> Enum.filter(&Variable.output?(&1))

        "intermediate" ->
          variables
          |> Enum.filter(&(!Variable.input?(&1) && !Variable.output?(&1)))

        nil ->
          variables
      end

    collection
    |> Enum.flat_map(&flatten_variable_tree(&1))
  end

  @doc """
  Get the variable with the given path in the given collection.
  """
  def get_variable_at(collection, path) do
    get_variable_at(collection, [], path)
  end

  defp get_variable_at(collection, traversed_path, [leaf]) do
    collection
    |> Enum.find(&(&1.path == traversed_path ++ [leaf]))
  end

  defp get_variable_at(collection, traversed_path, [next | tail]) do
    variable =
      collection
      |> Enum.find(&(&1.path == traversed_path ++ [next]))

    get_variable_at(variable.children, traversed_path ++ [next], tail)
  end

  @doc """
  Get the (flattened) container variables.
  An optional argument can define a mapping filter.
  """
  def get_containers(variables, mapping \\ nil) do
    variables
      |> flatten_variables(mapping)
      |> Enum.filter(&(&1.type == :map))
  end
end
