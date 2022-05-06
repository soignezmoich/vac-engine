defmodule VacEngineWeb.KlassHelpers do
  @moduledoc false

  def klass(base, conditionals) when is_list(conditionals) do
    conditionals
    |> Enum.reduce([base], fn
      {n, true}, all -> [n | all]
      {_n, _}, all -> all
    end)
    |> Enum.join(" ")
  end

  def klass(base, conditionals), do: klass(base, [conditionals])
end
