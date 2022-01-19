defmodule VacEngine.SimulationHelpers do

  def get_value(tree, variable_path) do
    case {tree, variable_path} do
      {nil, _} -> nil # absent in tree
      {tree, []} -> tree # remaining tree (either leaf or map) is the expected value
      {tree, [head|tail]} ->
        try do
          get_value(tree[String.to_existing_atom(head)], tail) # traverse recursively
        rescue
          ArgumentError -> nil # tree doesnt contain the variable
        end
    end
  end

  def variable_forbidden?(forbidden_tree, variable_path) do
    case {forbidden_tree, variable_path} do
      {nil, _} -> false # absent in tree
      {true, []} -> true # variable itself is marked as forbidden
      {true, _} -> false # parent is marked as forbidden
      {forbidden_tree, [head|tail]} -> # remaining tree and remaining path -> traverse recursively
        try do
          variable_forbidden?(forbidden_tree[String.to_existing_atom(head)], tail)
        rescue
          ArgumentError -> false # should never happen
        end
    end
  end

  def check_mismatch?({expected, forbidden, actual}) do
    case {expected, forbidden, actual} do
      {nil, true, nil} -> false # forbidden and absent
      {nil, true, _not_nil} -> true # forbidden not present
      {nil, false, _any} -> false # noting expected or forbidden
      {expected, false, actual} when expected == actual -> false # expect and actual match
      {expected, false, actual} when expected != actual -> true # expect and actual mismatch
    end
  end

  def variable_mismatch?(output_variable, kase) do
    output_variable
      |> get_expected_forbidden_actual(kase)
      |> check_mismatch?()
  end



  def case_mismatch?(output_variables, kase) do
    output_variables
      |> Enum.find(&(variable_mismatch?(&1, kase)))
  end


  defp get_expected_forbidden_actual(variable, kase) do
    {
      Map.get(kase, :expect, %{}) |> get_value(variable.path),
      Map.get(kase, :forbid, %{}) |> variable_forbidden?(variable.path),
      Map.get(kase, :actual, %{}) |> get_value(variable.path),
    }
  end

end
