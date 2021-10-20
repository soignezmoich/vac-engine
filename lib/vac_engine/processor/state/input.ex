defmodule VacEngine.Processor.State.Input do
  require VacEngine.Processor.Meta
  alias VacEngine.Processor.Meta
  alias VacEngine.Processor.Convert
  alias VacEngine.Processor.State
  alias VacEngine.Processor.Variable
  import VacEngine.Processor.State.List
  import VacEngine.Processor.State.Helpers
  import VacEngine.TupleHelpers

  def map_input(%State{input_variables: vars} = state, input)
      when is_map(input) do
    {input, hits} = map_variables(vars, input, %{}, [], %{})
    stack = lists_to_maps(input, vars)

    vars
    |> Enum.each(fn {path, var} ->
      if Variable.required?(var) do
        hit = hits |> Map.get(path)

        unless hit do
          throw(
            {:variable_required, "variable #{Enum.join(path, ".")} is required"}
          )
        end
      end
    end)

    %{state | input: input, stack: stack}
    |> ok()
  catch
    {_code, msg} ->
      {:error, msg}
  end

  def map_input(_, _) do
    {:error, "data to filter must be a map"}
  end

  defp map_variables(vars, data, mapped_data, parents, hits) do
    data
    |> Enum.reduce({mapped_data, hits}, fn {key, value}, {mapped_data, hits} ->
      map_variable(vars, value, mapped_data, parents ++ [key], hits)
    end)
  end

  defp map_variable(vars, value, mapped_data, path, hits) do
    vpath = Enum.reject(path, &is_function/1)
    var = vars |> Map.get(vpath)
    type = var |> get_type

    in_list = is_function(List.last(path))

    cond do
      is_list(value) && Meta.list_type?(type) ->
        {mapped_data, hits} =
          List.duplicate(nil, length(value))
          |> store(mapped_data, hits, path, vpath)

        value
        |> Enum.with_index()
        |> Enum.reduce({mapped_data, hits}, fn {el, idx}, {mapped_data, hits} ->
          map_variable(vars, el, mapped_data, path ++ [Access.at(idx)], hits)
        end)

      is_map(value) && Meta.is_type?(type, :map, in_list) ->
        mapped_data = put_in(mapped_data, path, %{})
        map_variables(vars, value, mapped_data, path, hits)

      is_integer(value) && Meta.is_type?(type, :integer, in_list) ->
        check_enum(var, value)
        store(value, mapped_data, hits, path, vpath)

      is_number(value) && Meta.is_type?(type, :number, in_list) ->
        check_enum(var, value)
        store(value, mapped_data, hits, path, vpath)

      is_binary(value) && Meta.is_type?(type, :string, in_list) ->
        check_enum(var, value)
        store(value, mapped_data, hits, path, vpath)

      is_boolean(value) && Meta.is_type?(type, :boolean, in_list) ->
        store(value, mapped_data, hits, path, vpath)

      is_binary(value) && Meta.is_type?(type, :boolean, in_list) ->
        value = Convert.parse_bool(value)
        store(value, mapped_data, hits, path, vpath)

      is_binary(value) && Meta.is_type?(type, :date, in_list) ->
        value = Convert.parse_date(value)
        store(value, mapped_data, hits, path, vpath)

      is_binary(value) && Meta.is_type?(type, :datetime, in_list) ->
        value = Convert.parse_datetime(value)
        store(value, mapped_data, hits, path, vpath)

      not is_nil(var) ->
        throw(
          {:invalid_value,
           "value #{clean_inspect(value)} is invalid for #{clean_inspect(vpath)}"}
        )

      true ->
        {mapped_data, hits}
    end
  end

  defp store(value, mapped_data, hits, path, vpath) do
    {_, hits} =
      vpath
      |> Enum.reduce({[], hits}, fn path, {stack, hits} ->
        stack = stack ++ [path]
        hits = Map.put(hits, stack, true)
        {stack, hits}
      end)

    {put_in(mapped_data, path, value), hits}
  end

  defp check_enum(%Variable{enum: nil}, value), do: value

  defp check_enum(%Variable{enum: values}, value) do
    values
    |> Enum.member?(value)
    |> case do
      false ->
        throw(
          {:invalid_value,
           "value #{value} not found in enum #{Enum.join(values, ",")}"}
        )

      true ->
        value
    end
  end

  defp clean_inspect([v]) do
    clean_inspect(v)
  end

  defp clean_inspect(v) do
    v
    |> inspect()
    |> String.replace(~r/"/, "")
  end
end
