defmodule VacEngine.Processor.State do
  alias VacEngine.Processor.State
  alias VacEngine.Processor.Compiler
  alias VacEngine.Processor.Variable
  alias VacEngine.Processor.Meta
  alias VacEngine.Processor.Convert
  require VacEngine.Processor.Meta
  import VacEngine.TupleHelpers

  defstruct variables: nil,
            input_variables: nil,
            output_variables: nil,
            stack: %{},
            input: %{},
            output: %{}

  def new(vars) do
    vars = flatten_variables(vars)

    {input_vars, output_vars} =
      vars
      |> Enum.reduce({%{}, %{}}, fn {path, var}, {input_vars, output_vars} ->
        input_vars =
          if Variable.input?(var) do
            Map.put(input_vars, path, var)
          else
            input_vars
          end

        output_vars =
          if Variable.output?(var) do
            Map.put(output_vars, path, var)
          else
            output_vars
          end

        {input_vars, output_vars}
      end)

    vars = vars |> Enum.map(fn {path, v} -> {path, v} end) |> Map.new()

    %State{
      input_variables: input_vars,
      output_variables: output_vars,
      variables: vars
    }
    |> ok()
  catch
    {_code, msg} ->
      {:error, msg}
  end

  def flatten_variables(vars, acc \\ {%{}, []})

  def flatten_variables(vars, {map, parents}) do
    vars
    |> Enum.reduce(
      map,
      fn %Variable{name: name, children: children} = var, map ->
        parents = parents ++ [name]
        default = Compiler.compile_expression!(var.default)
        map = Map.put(map, parents, %{var | default: default})
        flatten_variables(children, {map, parents})
      end
    )
  end

  def map_input(%State{input_variables: vars} = state, input)
      when is_map(input) do
    input = map_variables(vars, input, %{}, [])
    stack = lists_to_maps(input, vars)
    # TODO required variables?
    %{state | input: input, stack: stack}
    |> ok()
  catch
    {_code, msg} ->
      {:error, msg}
  end

  def map_variables(vars, data, mapped_data, parents) do
    data
    |> Enum.reduce(mapped_data, fn {key, value}, mapped_data ->
      map_variable(vars, value, mapped_data, parents ++ [key])
    end)
  end

  def map_variables(_, _) do
    throw({:invalid_data, "data to filter must be a map"})
  end

  def map_variable(vars, value, mapped_data, path) do
    vpath = Enum.reject(path, &is_function/1)
    type = vars |> Map.get(vpath) |> get_type

    in_list = is_function(List.last(path))

    cond do
      is_list(value) && Meta.is_list_type?(type) ->
        mapped_data =
          put_in(mapped_data, path, List.duplicate(nil, length(value)))

        value
        |> Enum.with_index()
        |> Enum.reduce(mapped_data, fn {el, idx}, mapped_data ->
          map_variable(vars, el, mapped_data, path ++ [Access.at(idx)])
        end)

      is_map(value) && Meta.is_type?(type, :map, in_list) ->
        mapped_data = put_in(mapped_data, path, %{})
        map_variables(vars, value, mapped_data, path)

      is_integer(value) && Meta.is_type?(type, :integer, in_list) ->
        put_in(mapped_data, path, value)

      is_binary(value) && Meta.is_type?(type, :string, in_list) ->
        put_in(mapped_data, path, value)

      is_boolean(value) && Meta.is_type?(type, :boolean, in_list) ->
        put_in(mapped_data, path, value)

      is_binary(value) && Meta.is_type?(type, :boolean, in_list) ->
        value = Convert.parse_bool(value)
        put_in(mapped_data, path, value)

      is_number(value) && Meta.is_type?(type, :number, in_list) ->
        put_in(mapped_data, path, value)

      is_binary(value) && Meta.is_type?(type, :date, in_list) ->
        value = Convert.parse_date(value)
        put_in(mapped_data, path, value)

      is_binary(value) && Meta.is_type?(type, :datetime, in_list) ->
        value = Convert.parse_datetime(value)
        put_in(mapped_data, path, value)

      true ->
        mapped_data
    end
  end

  def get_var(%State{variables: vars} = state, name_path) do
    path = cast_path(name_path)
    vpath = path |> Enum.reject(&is_integer/1)
    gpath = path |> Enum.map(&Access.key!/1)

    if vars != nil do
      var = Map.get(vars, vpath)

      if is_nil(var) do
        throw({:invalid_path, "invalid variable path #{inspect(path)}"})
      end

      try do
        get_in(state.stack, gpath)
      rescue
        _e in KeyError ->
          {:ok, res} = Compiler.eval_ast(var.default, %{state | variables: nil})
          res
      end
    else
      try do
        get_in(state.stack, gpath)
      rescue
        _e in KeyError ->
          throw({:invalid_path, "variable #{to_string(path)} not found"})
      end
    end
  end

  def merge_vars(%State{} = state, assigns) do
    assigns
    |> Enum.reduce(state, fn {path, value}, state ->
      set_var(state, path, value)
    end)
  end

  def set_var(
        %State{stack: stack, variables: vars} = state,
        path,
        value
      ) do
    path = cast_path(path)
    vpath = Enum.reject(path, &is_number/1)
    type = vars |> Map.get(vpath) |> get_type()
    ptype = vars |> Map.get(Enum.drop(vpath, -1)) |> get_type()

    in_list = Meta.is_list_type?(type)

    cond do
      # We are setting the whole list at once, iterate it and recurse call
      is_list(value) && in_list ->
        value
        |> Enum.with_index()
        |> Enum.reduce(state, fn {el, idx}, state ->
          path = path ++ [idx]
          set_var(state, path, el)
        end)

      # We are setting the whole map at once, iterate it and recurse call
      is_map(value) && type == :map ->
        value
        |> Enum.reduce(state, fn {key, value}, state ->
          path = path ++ [key]
          set_var(state, path, value)
        end)

      true ->
        compatible =
          (is_list(value) && Meta.is_list_type?(ptype)) ||
            (is_map(value) && Meta.is_type?(type, :map, in_list)) ||
            (is_integer(value) && Meta.is_type?(type, :integer, in_list)) ||
            (is_binary(value) && Meta.is_type?(type, :string, in_list)) ||
            (is_boolean(value) && Meta.is_type?(type, :boolean, in_list)) ||
            (is_number(value) && Meta.is_type?(type, :number, in_list)) ||
            (is_struct(value, NaiveDateTime) &&
               Meta.is_type?(type, :date, in_list)) ||
            (is_struct(value, Date) &&
               Meta.is_type?(type, :date, in_list)) ||
            (is_struct(value, NaiveDateTime) &&
               Meta.is_type?(type, :datetime, in_list))

        if compatible do
          stack =
            create_parents(vars, stack, path)
            |> put_in(path, value)

          %{state | stack: stack}
        else
          state
        end
    end
  end

  def finalize_output(%State{stack: stack, output_variables: vars} = state) do
    output =
      stack
      |> filter_vars(vars)
      |> maps_to_lists(vars)

    %{state | output: output}
    |> ok()
  catch
    {_code, msg} ->
      {:error, msg}
  end

  defp filter_vars(data, vars) do
    filter_vars(data, vars, [])
  end

  defp filter_vars(data, vars, path)
       when is_map(data) and not is_struct(data) do
    data
    |> Enum.map(fn {key, val} ->
      path =
        if is_integer(key) do
          path
        else
          path ++ [key]
        end

      if Map.get(vars, path) do
        {key, filter_vars(val, vars, path)}
      else
        nil
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> Map.new()
  end

  defp filter_vars(data, _vars, _path) when is_list(data) do
    throw({:invalid_data, "list is not supported in data"})
  end

  defp filter_vars(data, vars, path)
       when is_struct(data, NaiveDateTime) or
              is_struct(data, Date) do
    vars
    |> Map.get(path)
    |> get_type()
    |> case do
      :date ->
        Timex.format!(data, "{ISOdate}")

      :datetime ->
        Timex.format!(data, "{ISO:Extended}")

      nil ->
        nil
    end
  end

  defp filter_vars(data, _vars, _path), do: data

  defp lists_to_maps(data, vars) do
    lists_to_maps(data, vars, [])
  end

  defp lists_to_maps(data, vars, path)
       when is_map(data) and not is_struct(data) do
    data
    |> Enum.map(fn {key, value} ->
      path = path ++ [key]

      type = vars |> Map.get(path) |> get_type()

      if Meta.is_list_type?(type) do
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

  defp lists_to_maps(data, _vars, _path), do: data

  defp maps_to_lists(data, vars) do
    maps_to_lists(data, vars, [])
  end

  defp maps_to_lists(data, vars, path)
       when is_map(data) and not is_struct(data) do
    data
    |> Enum.map(fn {key, value} ->
      path = path ++ [key]
      type = vars |> Map.get(path) |> get_type()

      if Meta.is_list_type?(type) do
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

  defp maps_to_lists(data, _vars, _path), do: data

  defp create_parents(vars, map, path) do
    path
    |> Enum.reduce({map, []}, fn el, {map, parents} ->
      path = parents ++ [el]
      vpath = Enum.reject(path, &is_number/1)
      type = vars |> Map.get(vpath) |> get_type()

      {_, map} =
        if Meta.is_list_type?(type) || type == :map do
          get_and_update_in(map, path, fn current ->
            new = current || %{}
            {new, new}
          end)
        else
          {nil, map}
        end

      {map, path}
    end)
    |> elem(0)
  end

  defp cast_path(name) do
    name
    |> Meta.cast_path()
    |> case do
      {:ok, path} ->
        path

      {_, err} ->
        throw({:invalid_path, err})
    end
  end

  defp get_type(nil), do: nil
  defp get_type(var), do: var.type
end
