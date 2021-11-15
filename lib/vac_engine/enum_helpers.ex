defmodule VacEngine.EnumHelpers do
  @moduledoc """
  Set of Enum helpers
  """

  @doc """
  Nil safe get, return nil if map is nil
  """
  def get?(nil, _), do: nil
  def get?(map, key), do: Map.get(map, key)

  @doc """
  Get mixed first atom then string, nil safe
  """
  def get_mixed?(map, key, default \\ nil)
  def get_mixed?(nil, _, _), do: nil

  def get_mixed?(map, key, default) do
    if Map.has_key?(map, key) do
      Map.get(map, key, default)
    else
      Map.get(map, to_string(key), default)
    end
  end

  @doc """
  Remove nil AND empty lists from map
  """
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

  @doc """
  Find object in list by given key (list items must be map)
  """
  def find_by(list, key, value) do
    Enum.find(list, fn el ->
      Map.get(el, key) == value
    end)
  end
end
