defmodule VacEngineWeb.Editor.VariableRenderables do
  alias VacEngine.Processor.Variable, as: PVariable

  def build(variables, selection_dot_path) do
    input =
      variables
      |> Enum.filter(fn variable -> PVariable.input?(variable) end)
      |> Enum.flat_map(fn variable -> flatten_tree(["input"], variable) end)
      |> Enum.map(fn {path, variable} ->
        build_variable({path |> Enum.reverse(), variable}, selection_dot_path)
      end)

    output =
      variables
      |> Enum.filter(fn variable -> PVariable.output?(variable) end)
      |> Enum.flat_map(fn variable -> flatten_tree(["output"], variable) end)
      |> Enum.map(fn {path, variable} ->
        build_variable_with_default(
          {path |> Enum.reverse(), variable},
          selection_dot_path
        )
      end)

    intermediate =
      variables
      |> Enum.filter(fn variable ->
        !PVariable.input?(variable) && !PVariable.output?(variable)
      end)
      |> Enum.flat_map(fn variable ->
        flatten_tree(["intermediate"], variable)
      end)
      |> Enum.map(fn {path, variable} ->
        build_variable_with_default(
          {path |> Enum.reverse(), variable},
          selection_dot_path
        )
      end)

    %{
      input: input,
      output: output,
      intermediate: intermediate
    }
  end

  # Flatten the variable tree as a list and add path each variable.
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

  def build_variable_with_default({path, variable}, selection_dot_path) do
    default = variable.default
    base = build_variable({path, variable}, selection_dot_path)
    Map.merge(base, %{default: default})
  end

  def build_variable({path, variable}, selection_dot_path) do
    enum =
      case variable do
        %{enum: nil} -> []
        %{enum: enum} -> enum
        _ -> []
      end

    dot_path = path |> Enum.join(".")

    %{
      path: path,
      dot_path: dot_path,
      selected: dot_path == selection_dot_path,
      name: variable.name,
      type: variable.type,
      enum: enum
    }
  end
end
