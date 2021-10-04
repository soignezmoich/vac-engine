defmodule VacEngine.Processor.State do
  alias VacEngine.Processor.State
  alias VacEngine.Blueprints.Variable
  alias VacEngine.Processor.Meta
  require VacEngine.Processor.Meta

  defstruct input_variables: nil, output_variables: nil, input: %{}, output: %{}

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

    %State{input_variables: input_vars, output_variables: output_vars}
  end

  def with_input(input) do
    %State{input: input}
  end

  def flatten_variables(vars, acc \\ {%{}, []})

  def flatten_variables(vars, {map, parents}) do
    vars
    |> Enum.reduce(
      map,
      fn %Variable{name: name, children: children, type: type} = var, map ->
        parents = parents ++ [name]
        map = Map.put(map, parents, var)
        flatten_variables(children, {map, parents})
      end
    )
  end

  def map_input(%State{input_variables: vars} = state, input)
      when is_map(input) do
    input = map_variables(vars, input, %{}, [])
    %{state | input: input}
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

  defmacrop compatible(tname) do
    fname =
      if tname == :string do
        :binary
      else
        tname
      end

    quote do
      unquote(:"is_#{fname}")(var!(value)) &&
        ((!var!(in_list) && var!(type) == unquote(tname)) ||
           (var!(in_list) && var!(type) == unquote(:"#{tname}[]")))
    end
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

  def get_input(%State{} = state, name_path) do
    path =
      convert_path(name_path)
      |> Enum.map(fn
        el when is_integer(el) ->
          Access.at!(el)

        el when is_binary(el) ->
          Access.key!(el)
      end)

    get_in(state.input, path)
  end

  def merge_output(%State{} = state, assigns) do
    assigns
    |> Enum.reduce(state, fn {path, value}, state ->
      set_output(state, path, value)
    end)
  end

  def set_output(
        %State{output: output, output_variables: vars} = state,
        path,
        value
      ) do
    path = convert_path(path)
    vpath = Enum.reject(path, &is_number/1)
    type = Map.get(vars, vpath)
    ptype = Map.get(vars, Enum.drop(vpath, -1))

    in_list = Meta.is_list_type?(type)

    compatible =
      (is_list(value) && Meta.is_list_type?(ptype)) ||
        (is_map(value) && Meta.is_type?(type, :map, in_list)) ||
        (is_integer(value) && Meta.is_type?(type, :integer, in_list)) ||
        (is_binary(value) && Meta.is_type?(type, :string, in_list)) ||
        (is_boolean(value) && Meta.is_type?(type, :boolean, in_list)) ||
        (is_number(value) && Meta.is_type?(type, :number, in_list))

    if compatible do
      output =
        create_parents(vars, output, path)
        |> put_in(path, value)

      %{state | output: output}
    else
      state
    end
  end

  def finalize_output(%State{output: output, output_variables: vars} = state) do
    list_vars =
      vars
      |> Enum.to_list()
      |> Enum.filter(fn {path, type} -> Meta.is_list_type?(type) end)
      |> Enum.sort()

    output =
      list_vars
      |> Enum.reduce(output, fn {path, type}, output ->
        path = Enum.intersperse(path, Access.all())

        update_in(output, path, fn
          nil ->
            nil

          el ->
            el
            |> Enum.to_list()
            |> Enum.sort()
            |> Enum.map(fn {_idx, val} -> val end)
        end)
      end)

    %{state | output: output}
  end

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
end
