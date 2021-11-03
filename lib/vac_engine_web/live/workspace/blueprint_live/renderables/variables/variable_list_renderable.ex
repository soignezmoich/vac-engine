defmodule VacEngineWeb.Editor.VariableListRenderable do
  alias VacEngine.Processor.Variable, as: PVariable

  def build(variables) do
    input =
      variables
      |> Enum.filter(fn variable -> PVariable.input?(variable) end)
      |> Enum.flat_map(fn variable ->
        flatten_tree(["input", "variables"], variable)
      end)
      |> Enum.map(fn {path, variable} -> {path |> Enum.reverse(), variable} end)

    output =
      variables
      |> Enum.filter(fn variable -> PVariable.output?(variable) end)
      |> Enum.flat_map(fn variable ->
        flatten_tree(["output", "variables"], variable)
      end)
      |> Enum.map(fn {path, variable} -> {path |> Enum.reverse(), variable} end)

    intermediate =
      variables
      |> Enum.filter(fn variable ->
        !PVariable.input?(variable) && !PVariable.output?(variable)
      end)
      |> Enum.flat_map(fn variable ->
        flatten_tree(["intermediate", "variables"], variable)
      end)
      |> Enum.map(fn {path, variable} -> {path |> Enum.reverse(), variable} end)

    %{
      input: input,
      output: output,
      intermediate: intermediate
    }
  end

  # Flatten the variable tree as a (reversed) list and add path each variable.
  defp flatten_tree(parent_path, variable) do
    current_path = [variable.name | parent_path]

    case variable do
      %{children: children} ->
        [
          {current_path, variable}
          | children
            |> Enum.flat_map(fn child -> flatten_tree(current_path, child) end)
        ]

      _ ->
        [{current_path, variable}]
    end
  end
end
