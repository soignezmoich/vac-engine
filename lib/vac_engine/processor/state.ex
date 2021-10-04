defmodule VacEngine.Processor.State do
  alias VacEngine.Processor.State
  alias VacEngine.Blueprints.Variable
  alias VacEngine.Processor.Meta
  require VacEngine.Processor.Meta

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
          if var.input do
            Map.put(input_vars, path, var.type)
          else
            input_vars
          end

        output_vars =
          if var.output do
            Map.put(output_vars, path, var.type)
          else
            output_vars
          end

        {input_vars, output_vars}
      end)

    vars = vars |> Enum.map(fn {path, v} -> {path, v.type} end) |> Map.new()

    %State{
      input_variables: input_vars,
      output_variables: output_vars,
      variables: vars
    }
  end

  def flatten_variables(vars, acc \\ {%{}, []})

  def flatten_variables(vars, {map, parents}) do
    vars
    |> Enum.reduce(
      map,
      fn %Variable{name: name, children: children} = var, map ->
        parents = parents ++ [name]
        map = Map.put(map, parents, var)
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
  end

  def map_variables(vars, data, mapped_data, parents) do
    data
    |> Enum.reduce(mapped_data, fn {key, value}, mapped_data ->
      map_variable(vars, value, mapped_data, parents ++ [key])
    end)
  end

  def map_variables(_, _) do
    raise "data to filter must be a map"
  end

  def map_variable(vars, value, mapped_data, path) do
    vpath = Enum.reject(path, &is_function/1)
    type = Map.get(vars, vpath)

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

      is_number(value) && Meta.is_type?(type, :number, in_list) ->
        put_in(mapped_data, path, value)

      true ->
        mapped_data
    end
  end

  def get_var(%State{} = state, name_path) do
    path =
      convert_path(name_path)
      |> Enum.map(&Access.key!/1)

    get_in(state.stack, path)
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
    path = convert_path(path)
    vpath = Enum.reject(path, &is_number/1)
    type = Map.get(vars, vpath)
    ptype = Map.get(vars, Enum.drop(vpath, -1))

    in_list = Meta.is_list_type?(type)

    cond do
      is_list(value) && in_list ->
        # We are setting the whole list at once, iterate it and recurse call
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
            (is_number(value) && Meta.is_type?(type, :number, in_list))

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
  end

  defp filter_vars(data, vars) do
    filter_vars(data, vars, [])
  end

  defp filter_vars(data, vars, path) when is_map(data) do
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
    raise "list is not supported in data"
  end

  defp filter_vars(data, _vars, _path), do: data

  defp lists_to_maps(data, vars) do
    lists_to_maps(data, vars, [])
  end

  defp lists_to_maps(data, vars, path) when is_map(data) do
    data
    |> Enum.map(fn {key, value} ->
      path = path ++ [key]
      type = Map.get(vars, path)

      if Meta.is_list_type?(type) do
        unless is_list(value) do
          raise "value at #{path} must be a list"
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

  defp maps_to_lists(data, vars, path) when is_map(data) do
    data
    |> Enum.map(fn {key, value} ->
      path = path ++ [key]
      type = Map.get(vars, path)

      if Meta.is_list_type?(type) do
        unless is_map(value) do
          raise "value at #{path} must be a map with integer keys"
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

  # defp intersperse_all_access(path, vars) do
  #   current = Enum.at(path, -1)
  #   path = Enum.drop(path, -1)
  #
  #   path
  #   |> Enum.flat_map_reduce([], fn el, acc ->
  #     acc = acc ++ [el]
  #     type = Map.get(vars, acc)
  #
  #     if Meta.is_list_type?(type) do
  #       {[el, Access.all()], acc}
  #     else
  #       {[el], acc}
  #     end
  #   end)
  #   |> elem(0)
  #   |> Enum.concat([current])
  # end
  #
  # defp lists_to_maps(data, vars) do
  #   vars = vars
  #   |> filter_list_vars()
  #   |> Enum.reverse()
  #
  #   lists_to_maps(data, vars, [])
  # end
  #
  # defp lists_to_maps(data, vars, path) when is_map(data) do
  #   data
  #   |> Enum.map(fn {key, value} ->
  #     type = Map.get(vars, path ++ [key])
  #     if Meta.is_list_type?(type) do
  #     end
  #   end)
  #   |> Map.new()
  #
  #   #|> Enum.reduce(data, fn {path, type}, data ->
  #   #  path = intersperse_all_access(path, vars)
  #
  #   #  if path_exists?(data, path) do
  #   #    update_in(data, path, fn
  #   #      nil ->
  #   #        nil
  #
  #   #      el ->
  #   #        el
  #   #        |> Enum.with_index()
  #   #        |> Enum.map(fn {a, b} -> {b, a} end)
  #   #        |> Map.new()
  #   #    end)
  #   #  else
  #   #    data
  #   #  end
  #   #end)
  # end
  #
  # defp maps_to_lists(data, vars) do
  #   IO.inspect("----------------")
  #   IO.inspect(data)
  #
  #   vars
  #   |> filter_list_vars()
  #   |> Enum.reduce(data, fn {path, type}, data ->
  #     path = intersperse_all_access(path, vars)
  #
  #     IO.inspect(path)
  #
  #     if path_exists?(data, path) do
  #       update_in(data, path, fn
  #         nil ->
  #           nil
  #
  #         el ->
  #           el
  #           |> Enum.to_list()
  #           |> Enum.sort()
  #           |> Enum.map(fn {_idx, val} -> val end)
  #       end)
  #     else
  #       data
  #     end
  #   end)
  # end

  # defp filter_list_vars(vars) do
  #   vars
  #   |> Enum.to_list()
  #   |> Enum.filter(fn {path, type} -> Meta.is_list_type?(type) end)
  #   |> Enum.sort()
  # end

  defp create_parents(vars, map, path) do
    path
    |> Enum.reduce({map, []}, fn el, {map, parents} ->
      path = parents ++ [el]
      vpath = Enum.reject(path, &is_number/1)
      type = Map.get(vars, vpath)

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

  defp convert_path(name) when is_binary(name) do
    convert_path([name])
  end

  defp convert_path(name) when is_atom(name) do
    convert_path([Atom.to_string(name)])
  end

  defp convert_path(name_path) when is_list(name_path) do
    name_path
    |> Enum.map(fn
      el when is_integer(el) ->
        el

      el when is_binary(el) ->
        Integer.parse(el)
        |> case do
          {index, _} -> index
          _ -> el
        end

      el ->
        if not is_binary(el) do
          raise "invalid variable path #{inspect(el)}"
        end
    end)
  end

  defp convert_path(name) do
    raise "invalid variable path #{inspect(name)}"
  end

  # defp path_exists?(map, path) do
  #   IO.puts("check check")
  #   IO.inspect(map)
  #   IO.inspect(path)
  #   path
  #   |> Enum.drop(-1)
  #   |> Enum.reduce_while({[], true}, fn el, {path, res} ->
  #     path = path ++ [el]
  #
  #     IO.puts("pppppppppppppp")
  #     IO.puts("xxxxxxxxxxxxxxxxxxxxxxx")
  #     IO.inspect(path)
  #     val = get_in(map, path)
  #
  #     exists =
  #       case val do
  #         nil -> false
  #         [] -> false
  #         val when is_list(val) -> !Enum.all?(val, &is_nil/1)
  #         _ -> true
  #       end
  #
  #     if exists do
  #       {:cont, {path, res}}
  #     else
  #       {:halt, {path, false}}
  #     end
  #   end)
  #   |> elem(1)
  #   |> IO.inspect()
  # end
end
