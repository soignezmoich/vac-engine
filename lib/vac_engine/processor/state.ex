defmodule VacEngine.Processor.State do
  @moduledoc """
  Processor state
  """
  alias VacEngine.Processor.State
  alias VacEngine.Processor.Compiler
  alias VacEngine.Processor.Variable
  alias VacEngine.Processor.Meta
  alias VacEngine.Processor.State.Input
  alias VacEngine.Processor.State.Env
  require VacEngine.Processor.Meta
  import VacEngine.Processor.State.Helpers
  import VacEngine.PipeHelpers
  import VacEngine.Processor.State.List
  require Logger

  defstruct variables: nil,
            input_variables: nil,
            output_variables: nil,
            env: %{},
            heap: %{},
            input: %{},
            output: %{}

  @doc """
  Init with blueprint variables
  """
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

    vars = Map.new(vars)

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

  defp flatten_variables(vars, acc \\ {%{}, []})

  defp flatten_variables(vars, {map, parents}) do
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

  defdelegate map_input(state, input), to: Input
  defdelegate map_env(state, env), to: Env

  def set_defaults(%State{output_variables: output_vars} = state) do
    output_vars
    |> Enum.reject(fn {_path, var} ->
      var.in_list
    end)
    |> Enum.reduce(state, fn {path, _v}, state ->
      set_var(state, path, get_var(state, path))
    end)
    |> ok()
  end

  @doc """
  Get value of variable (used by blueprint compiled code)
  """
  def get_var(%State{variables: nil} = state, name_path) do
    path = cast_path(name_path)
    gpath = path |> Enum.map(&Access.key!/1)

    try do
      get_in(state.heap, gpath)
    rescue
      _e in KeyError ->
        throw({:invalid_path, "variable #{to_string(path)} not found"})
    end
  end

  def get_var(%State{variables: vars} = state, name_path) do
    path = cast_path(name_path)
    vpath = path |> Enum.reject(&is_integer/1)
    gpath = path |> Enum.map(&Access.key!/1)

    var = Map.get(vars, vpath)

    if is_nil(var) do
      throw({:invalid_path, "invalid variable path #{inspect(path)}"})
    end

    try do
      get_in(state.heap, gpath)
    rescue
      _e in KeyError ->
        {_, variables} = Map.pop(state.variables, var.path)

        {:ok, res} =
          Compiler.eval_ast(var.default, %{state | variables: variables})

        res
    end
  end

  @doc """
  Set values of variables (used by blueprint compiled code)
  """
  def merge_vars(%State{} = state, assigns) do
    assigns
    |> Enum.reduce(state, fn {path, value}, state ->
      set_var(state, path, value)
    end)
  end

  @doc """
  Set value of variable (used by blueprint compiled code)
  """
  def set_var(
        %State{heap: heap, variables: vars} = state,
        path,
        value
      ) do
    path = cast_path(path)
    vpath = Enum.reject(path, &is_number/1)
    type = vars |> Map.get(vpath) |> get_type()
    ptype = vars |> Map.get(Enum.drop(vpath, -1)) |> get_type()

    in_list = Meta.list_type?(type)

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
        {compatible, value} = map_value(value, type, ptype, in_list)

        if compatible do
          heap =
            create_parents(vars, heap, path)
            |> put_in(path, value)

          %{state | heap: heap}
        else
          state
        end
    end
  end

  defp map_value(value, type, ptype, in_list) do
    cond do
      is_list(value) && Meta.list_type?(ptype) ->
        {true, value}

      is_map(value) && Meta.is_type?(type, :map, in_list) ->
        {true, value}

      is_integer(value) && Meta.is_type?(type, :integer, in_list) ->
        {true, value}

      is_binary(value) && Meta.is_type?(type, :string, in_list) ->
        {true, value}

      is_boolean(value) && Meta.is_type?(type, :boolean, in_list) ->
        {true, value}

      is_number(value) && Meta.is_type?(type, :number, in_list) ->
        {true, value}

      is_struct(value, NaiveDateTime) && Meta.is_type?(type, :date, in_list) ->
        {true, value}

      is_struct(value, Date) && Meta.is_type?(type, :date, in_list) ->
        {true, value}

      is_struct(value, NaiveDateTime) && Meta.is_type?(type, :datetime, in_list) ->
        {true, value}

      true ->
        {false, nil}
    end
  end

  @doc """
  Convert heap into output format for returning result
  """
  def finalize_output(%State{heap: heap, output_variables: vars} = state) do
    output =
      heap
      |> filter_vars(vars)
      |> maps_to_lists(vars)

    Logger.info("Output: #{inspect(output)}")

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
        Timex.format!(data, "{ISO:Extended:Z}")

      nil ->
        nil
    end
  end

  defp filter_vars(data, _vars, _path), do: data

  defp create_parents(vars, map, path) do
    path
    |> Enum.reduce({map, []}, fn el, {map, parents} ->
      path = parents ++ [el]
      vpath = Enum.reject(path, &is_number/1)
      type = vars |> Map.get(vpath) |> get_type()

      {_, map} =
        if Meta.list_type?(type) || type == :map do
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
end
