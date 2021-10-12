defmodule VacEngine.Processor.Meta do
  import VacEngine.TupleHelpers

  @types ~w(
    boolean
    integer
    number
    string
    date
    datetime
    map
    boolean[]
    integer[]
    number[]
    string[]
    date[]
    datetime[]
    map[]
  )a

  def types(), do: @types

  def is_list_type?(:"boolean[]"), do: true
  def is_list_type?(:"integer[]"), do: true
  def is_list_type?(:"number[]"), do: true
  def is_list_type?(:"string[]"), do: true
  def is_list_type?(:"date[]"), do: true
  def is_list_type?(:"datetime[]"), do: true
  def is_list_type?(:"map[]"), do: true
  def is_list_type?(_), do: false

  def has_nested_type?(:"map[]"), do: true
  def has_nested_type?(:map), do: true
  def has_nested_type?(_), do: false

  defmacro is_type?(type, tname, in_list) do
    quote do
      (!unquote(in_list) && unquote(type) == unquote(tname)) ||
        (unquote(in_list) && unquote(type) == unquote(:"#{tname}[]"))
    end
  end

  def cast_path(name) when is_binary(name) do
    cast_path([name])
  end

  def cast_path(name) when is_atom(name) do
    cast_path([Atom.to_string(name)])
  end

  def cast_path(name_path) when is_list(name_path) do
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
          throw({:invalid_path, "invalid variable path #{inspect(el)}"})
        end
    end)
    |> ok()
  catch
    {_, err} ->
      {:error, err}
  end

  def cast_path(name) do
    {:error, "invalid variable path #{inspect(name)}"}
  end
end
