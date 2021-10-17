defmodule VacEngine.Processor.Library do
  use VacEngine.Processor.Library.Import

  def has_function?(fname, arity) do
    functions()
    |> Map.get(fname, %{})
    |> Map.get(arity)
    |> is_map()
  end

  def get_signature(fname, arg_types) do
    arity = length(arg_types)

    functions()
    |> Map.get(fname, %{})
    |> Map.get(arity)
    |> case do
      nil ->
        nil

      %{signatures: sigs} ->
        sigs
        |> Enum.find(fn
          {^arg_types, _} -> true
          {args, _} -> args_match?(args, arg_types)
          _ -> false
        end)
    end
  end

  defp args_match?(a, b) when length(a) != length(b), do: false

  defp args_match?(a, b) do
    Enum.zip(a, b)
    |> Enum.all?(fn {a, b} ->
      a == b || a == :any
    end)
  end
end
