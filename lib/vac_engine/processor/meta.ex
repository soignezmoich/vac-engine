defmodule VacEngine.Processor.Meta do
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
end
