defmodule VacEngine.SimulationHelpers do
  @moduledoc false

  def get_value(tree, variable_path) do
    case {tree, variable_path} do
      # absent in tree
      {nil, _} ->
        nil

      # remaining tree (either leaf or map) is the expected value
      {tree, []} ->
        tree

      {tree, [head | tail]} ->
        try do
          # traverse recursively
          get_value(tree[String.to_existing_atom(head)], tail)
        rescue
          # tree doesnt contain the variable
          ArgumentError -> nil
        end
    end
  end

  def variable_forbidden?(forbidden_tree, variable_path) do
    case {forbidden_tree, variable_path} do
      # absent in tree
      {nil, _} ->
        false

      # variable itself is marked as forbidden
      {true, []} ->
        true

      # parent is marked as forbidden
      {true, _} ->
        false

      # remaining tree and remaining path -> traverse recursively
      {forbidden_tree, [head | tail]} ->
        try do
          variable_forbidden?(
            forbidden_tree[String.to_existing_atom(head)],
            tail
          )
        rescue
          # should never happen
          ArgumentError -> false
        end
    end
  end

  def check_mismatch?({expected, forbidden, actual}) do
    case {expected, forbidden, actual} do
      # forbidden and absent
      {nil, true, nil} -> false
      # forbidden not present
      {nil, true, _not_nil} -> true
      # noting expected or forbidden
      {nil, false, _any} -> false
      # expect and actual match
      {expected, false, actual} when expected == actual -> false
      # expect and actual mismatch
      {expected, false, actual} when expected != actual -> true
    end
  end

  def variable_mismatch?(output_variable, kase) do
    output_variable
    |> get_expected_forbidden_actual(kase)
    |> check_mismatch?()
  end

  def case_mismatch?(output_variables, kase) do
    output_variables
    |> Enum.find(&variable_mismatch?(&1, kase))
  end

  defp get_expected_forbidden_actual(variable, kase) do
    {
      Map.get(kase, :expect, %{}) |> get_value(variable.path),
      Map.get(kase, :forbid, %{}) |> variable_forbidden?(variable.path),
      Map.get(kase, :actual, %{}) |> get_value(variable.path)
    }
  end

  def variable_default_value(type, enum) do
    case {type, enum} do
      {:boolean, _} -> "false"
      {:string, nil} -> "<enter value>"
      {:string, enum} -> enum |> List.first() || ""
      {:date, _} -> "2000-01-01"
      {:datetime, _} -> "2000-01-01T00:00:00"
      {:number, _} -> "0.0"
      {:integer, _} -> "0"
      {:map, _} -> "<map>"
    end
  end
end
