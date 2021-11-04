defmodule VacEngine.Processor.State.List do
  @moduledoc """
  State heplers to manipulate list varibales
  """
  require VacEngine.Processor.Meta
  alias VacEngine.Processor.Meta
  import VacEngine.Processor.State.Helpers

  @doc """
  Convert all lists into data into maps with integer keys

  Vars is used for type lookup
  """
  def lists_to_maps(data, vars) do
    lists_to_maps(data, vars, [])
  end

  def lists_to_maps(data, vars, path)
      when is_map(data) and not is_struct(data) do
    data
    |> Enum.map(fn {key, value} ->
      path = path ++ [key]

      type = vars |> Map.get(path) |> get_type()

      if Meta.list_type?(type) do
        unless is_list(value) do
          throw({:invalid_value, "value at #{path} must be a list"})
        end

        value =
          value
          |> Enum.with_index()
          |> Enum.map(fn {a, b} ->
            {b, lists_to_maps(a, vars, path)}
          end)
          |> Map.new()

        {key, value}
      else
        {key, lists_to_maps(value, vars, path)}
      end
    end)
    |> Map.new()
  end

  def lists_to_maps(data, _vars, _path), do: data

  @doc """
  Convert all map as lists into data into real lists

  Vars is used for type lookup
  """
  def maps_to_lists(data, vars) do
    maps_to_lists(data, vars, [])
  end

  def maps_to_lists(data, vars, path)
      when is_map(data) and not is_struct(data) do
    data
    |> Enum.map(fn {key, value} ->
      path = path ++ [key]
      type = vars |> Map.get(path) |> get_type()

      if Meta.list_type?(type) do
        unless is_map(value) do
          throw(
            {:invalid_value, "value at #{path} must be a map with integer keys"}
          )
        end

        value =
          value
          |> Enum.to_list()
          |> Enum.sort()
          |> Enum.map(fn {_idx, value} ->
            maps_to_lists(value, vars, path)
          end)

        {key, value}
      else
        {key, maps_to_lists(value, vars, path)}
      end
    end)
    |> Map.new()
  end

  def maps_to_lists(data, _vars, _path), do: data
end
