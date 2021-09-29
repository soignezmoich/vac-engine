defmodule VacEngine.Processor.Libraries do
  # This is a placeholder for AST compilation
  # that will be replaced by the compiler
  def var(name), do: name

  def is_false(false), do: true
  def is_false(_), do: false

  def is_true(true), do: true
  def is_true(_), do: false

  def not true, do: false
  def not false, do: true

  def not _ do
    raise "not cannot be used for non boolean"
  end

  def eq(a, b) when is_float(a) or is_float(b) do
    raise "eq cannot be used for non integer"
  end

  @doc """
    Check equality of two expressions.
  """
  @doc interfaces: [
         {{:integer, :integer}, :boolean},
         {{:boolean, :boolean}, :boolean},
         {{:date, :date}, :boolean}
       ]
  def eq(a, b) do
    a == b
  end

  def neq(a, b) do
    !eq(a, b)
  end

  def gt(a, b) do
    a > b
  end

  def gte(a, b) do
    a >= b
  end

  def lt(a, b) do
    a < b
  end

  def lte(a, b) do
    a <= b
  end

  def add(a, b) do
    a + b
  end

  def sub(a, b) do
    a - b
  end

  def mult(a, b) do
    a * b
  end

  def div(a, b) do
    a / b
  end

  # list or string
  def contains(list, el) when is_list(list) do
    el in list
  end

  def contains(str, el) when is_binary(str) do
    String.contains?(str, to_string(el))
  end

  # TODO date functions

  def age_now(_birthdate) do
    85
  end
end
