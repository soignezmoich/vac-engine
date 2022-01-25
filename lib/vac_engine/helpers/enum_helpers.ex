defmodule VacEngine.EnumHelpers do
  @moduledoc """
  Set of Enum helpers
  """

  import VacEngine.PipeHelpers, only: [rpair: 2]

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

  @doc """
  Convert a nested map to an array of tuple with dotted path
  """
  def flatten_map(m, stack \\ [])

  def flatten_map(m, stack) when is_map(m) do
    Enum.reduce(m, [], fn {k, v}, acc ->
      flatten_map(v, stack ++ [k]) ++ acc
    end)
  end

  def flatten_map(val, stack) do
    [{stack, val}]
  end

  @doc """
  Convert a flat array to a nested map
  """
  def unflatten_map(a) when is_list(a) do
    Enum.reduce(a, %{}, fn {k, v}, acc ->
      path = k

      path
      |> Enum.drop(-1)
      |> Enum.reduce({acc, []}, fn el, {acc, path} ->
        path = path ++ [el]

        update_in(acc, path, fn current ->
          current || %{}
        end)
        |> rpair(path)
      end)
      |> elem(0)
      |> put_in(path, v)
    end)
  end

  @doc """
  Simple deep merge of map of map
  """
  def sdmerge(a, b) do
    Map.merge(a, b, &sdresolve/3)
  end

  defp sdresolve(_key, a, b) when is_map(a) and is_map(b) do
    sdmerge(a, b)
  end

  defp sdresolve(_key, _a, b) do
    b
  end
end
