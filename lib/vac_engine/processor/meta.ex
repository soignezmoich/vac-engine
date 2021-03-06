defmodule VacEngine.Processor.Meta do
  @moduledoc """
  Compiler helpers
  """
  import VacEngine.PipeHelpers

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

  def list_type?(t) when is_binary(t) do
    list_type?(String.to_existing_atom(t))
  rescue
    _ -> false
  end

  def list_type?(:"boolean[]"), do: true
  def list_type?(:"integer[]"), do: true
  def list_type?(:"number[]"), do: true
  def list_type?(:"string[]"), do: true
  def list_type?(:"date[]"), do: true
  def list_type?(:"datetime[]"), do: true
  def list_type?(:"map[]"), do: true
  def list_type?(_), do: false

  def container_type?(t) when is_binary(t) do
    container_type?(String.to_existing_atom(t))
  rescue
    _ -> false
  end

  def container_type?(:"map[]"), do: true
  def container_type?(:map), do: true
  def container_type?(_), do: false

  def enum_type?(t) when is_binary(t) do
    enum_type?(String.to_existing_atom(t))
  rescue
    _ -> false
  end

  def enum_type?(:integer), do: true
  def enum_type?(:string), do: true
  def enum_type?(_), do: false

  def itemize_type(:"boolean[]"), do: :boolean
  def itemize_type(:"integer[]"), do: :integer
  def itemize_type(:"number[]"), do: :number
  def itemize_type(:"string[]"), do: :string
  def itemize_type(:"date[]"), do: :date
  def itemize_type(:"datetime[]"), do: :datetime
  def itemize_type(:"map[]"), do: :map
  def itemize_type(t), do: t

  def of_type?(t, val) when is_binary(t) do
    of_type?(String.to_existing_atom(t), val)
  rescue
    _ -> false
  end

  def of_type?(:string, val) when is_binary(val), do: true
  def of_type?(:integer, val) when is_integer(val), do: true
  def of_type?(:number, val) when is_number(val), do: true
  def of_type?(:date, val) when is_struct(val, Date), do: true
  def of_type?(:date, val) when is_struct(val, NaiveDateTime), do: true
  def of_type?(:datetime, val) when is_struct(val, NaiveDateTime), do: true
  def of_type?(:map, val) when is_map(val), do: true
  def of_type?(_t, _val), do: false

  defmacro is_type?(type, tname, in_list) do
    quote do
      (!unquote(in_list) && unquote(type) == unquote(tname)) ||
        (unquote(in_list) && unquote(type) == unquote(:"#{tname}[]"))
    end
  end

  @doc """
  Convert a path to string and integers (remove atoms and parse ints)
  """
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

  @mappings ~w(
      in_required
      in_optional
      inout_required
      inout_optional
      out
      none
  )a

  def mappings(), do: @mappings

  def input?(nil), do: false

  def input?(mapping) when is_binary(mapping) do
    input?(String.to_existing_atom(mapping))
  end

  def input?(mapping) do
    case mapping do
      :in_required -> true
      :in_optional -> true
      :inout_required -> true
      :inout_optional -> true
      :out -> false
      :none -> false
    end
  end

  def output?(nil), do: false

  def output?(mapping) when is_binary(mapping) do
    output?(String.to_existing_atom(mapping))
  end

  def output?(mapping) do
    case mapping do
      :in_required -> false
      :in_optional -> false
      :inout_required -> true
      :inout_optional -> true
      :out -> true
      :none -> false
    end
  end

  def required?(nil), do: false

  def required?(mapping) when is_binary(mapping) do
    required?(String.to_existing_atom(mapping))
  end

  def required?(mapping) do
    case mapping do
      :in_required -> true
      :in_optional -> false
      :inout_required -> true
      :inout_optional -> false
      :out -> false
      :none -> false
    end
  end
end
