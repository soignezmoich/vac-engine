defmodule VacEngine.EnumHelpers do
  def get?(nil, _), do: nil
  def get?(map, key), do: Map.get(map, key)

  def compact(map) when is_map(map) do
    map
    |> Enum.filter(fn
      {_, nil} -> false
      {_, []} -> false
      _ -> true
    end)
    |> Map.new()
  end

  def compact(list) when is_list(list) do
    list
    |> Enum.filter(fn
      nil -> false
      [] -> false
      _ -> true
    end)
  end

  def find_by(list, key, value) do
    Enum.find(list, fn el ->
      Map.get(el, key) == value
    end)
  end
end
