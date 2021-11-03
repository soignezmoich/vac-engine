defmodule VacEngineWeb.Editor.VariableRenderable do
  alias VacEngine.Processor.Variable, as: PVariable

  def build(variable, path) do
    enum =
      case variable do
        %{enum: nil} -> []
        %{enum: enum} -> enum
        _ -> []
      end

    dot_path = path |> Enum.join(".")

    required = PVariable.required?(variable)

    %{
      path: path,
      dot_path: dot_path,
      required: required,
      name: variable.name,
      type: variable.type,
      enum: enum
    }
  end
end
