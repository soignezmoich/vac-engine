defmodule VacEngine.MapHelpers do
  def get?(nil, _), do: nil
  def get?(map, key), do: Map.get(map, key)

  def compact(map) do
    map
    |> Enum.filter(fn
      {_, nil} -> false
      {_, []} -> false
      _ -> true
    end)
    |> Map.new
  end
end
