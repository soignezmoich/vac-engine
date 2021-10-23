defmodule VacEngineWeb.Editor.ExpressionRenderables do
  def build(_use_case, nil) do
    "-"
  end

  def build(_use_case, {:var, _signature, [var_path]}) when is_list(var_path) do
    "@#{var_path |> Enum.join(".")}"
  end

  def build(use_case, {op, _signature, args}) do
    args =
      case use_case do
        "condition" -> Enum.drop(args, 1)
        _ -> args
      end

    # TODO load function definition

    args_text =
      args
      |> Enum.map(fn arg -> build(use_case, arg) end)
      |> Enum.join(", ")

    "#{op} #{args_text}"
  end

  def build(constant) do
    %{
      static_text: inspect(constant),
      args: []
    }
  end
end
