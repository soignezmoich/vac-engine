defmodule VacEngine.Processor.Library.Functions do
  use VacEngine.Processor.Library.Define

  # This is a placeholder for AST compilation
  # that will be replaced by the compiler
  @doc """
    Get a variable value
  """
  @label "Return a variable value"
  @short "VAR"
  @signature {[:varname], :vartype}
  def var(name), do: name

  @doc """
    Check if boolean is false

    Returns true if the boolean is nil
  """
  @label "Check if value is false"
  @short "FALSE"
  @signature {[:any], :boolean}
  def is_false(false), do: true
  def is_false(nil), do: true
  def is_false(_), do: false

  @doc """
    Check if boolean is true
  """
  @label "Check if value is true"
  @short "TRUE"
  @signature {[:boolean], :boolean}
  def is_true(true), do: true
  def is_true(_), do: false

  @doc """
    Inverse boolean
  """
  @label "Inverse"
  @short "!"
  @signature {[:boolean], :boolean}
  def not true, do: false
  def not false, do: true

  def not _ do
    throw({:argument_error, "not cannot be used for non boolean"})
  end

  @doc """
    Check if variable is nil

    Returns false only for nil
  """
  @label "Is nil"
  @short "NIL"
  @signature {[:any], :boolean}
  def is_nil(nil), do: true
  def is_nil(_), do: false

  @doc """
    Check if variable is not nil

    Returns true only for nil
  """
  @label "Is not nil"
  @short "NOT NIL"
  @signature {[:any], :boolean}
  def is_not_nil(nil), do: false
  def is_not_nil(_), do: true

  @doc false
  def eq(a, b) when is_float(a) or is_float(b) do
    throw({:argument_error, "eq cannot be used for non integer"})
  end

  @doc """
    Check equality of two expressions.
  """
  @label "Equals to"
  @short "="
  @signature {[:string, :string], :boolean}
  @signature {[:integer, :integer], :boolean}
  @signature {[:boolean, :boolean], :boolean}
  @signature {[:datetime, :datetime], :boolean}
  @signature {[:date, :date], :boolean}
  def eq(a, b) do
    a == b
  end

  @doc """
    Check inequality of two expressions.
  """
  @label "Not equal to"
  @short "≠"
  @signature {[:string, :string], :boolean}
  @signature {[:integer, :integer], :boolean}
  @signature {[:boolean, :boolean], :boolean}
  @signature {[:datetime, :datetime], :boolean}
  @signature {[:date, :date], :boolean}
  def neq(a, b) do
    !eq(a, b)
  end

  @doc """
    Check if a is greater than b. For date, a is after b.
  """
  @label "Greater than"
  @short ">"
  @signature {[:integer, :integer], :boolean}
  @signature {[:number, :number], :boolean}
  @signature {[:number, :integer], :boolean}
  @signature {[:integer, :number], :boolean}
  @signature {[:datetime, :datetime], :boolean}
  @signature {[:date, :date], :boolean}
  def gt(a, b) do
    a > b
  end

  @doc """
    Check if a is greater than or equal to b. For date, a is after b.
  """
  @label "Greater than or equal to"
  @short "≥"
  @signature {[:integer, :integer], :boolean}
  @signature {[:number, :number], :boolean}
  @signature {[:number, :integer], :boolean}
  @signature {[:integer, :number], :boolean}
  @signature {[:datetime, :datetime], :boolean}
  @signature {[:date, :date], :boolean}
  def gte(a, b) do
    a >= b
  end

  @doc """
    Check if a is less than b
  """
  @label "Less than"
  @short "<"
  @signature {[:integer, :integer], :boolean}
  @signature {[:number, :number], :boolean}
  @signature {[:number, :integer], :boolean}
  @signature {[:integer, :number], :boolean}
  @signature {[:datetime, :datetime], :boolean}
  @signature {[:date, :date], :boolean}
  def lt(a, b) do
    a < b
  end

  @doc """
    Check if a is less than or equal to b
  """
  @label "Less than or equal to"
  @short "≤"
  @signature {[:integer, :integer], :boolean}
  @signature {[:number, :number], :boolean}
  @signature {[:number, :integer], :boolean}
  @signature {[:integer, :number], :boolean}
  @signature {[:datetime, :datetime], :boolean}
  @signature {[:date, :date], :boolean}
  def lte(a, b) do
    a <= b
  end

  @doc """
    Add two values
  """
  @label "Add"
  @short "+"
  @signature {[:integer, :integer], :number}
  @signature {[:number, :number], :number}
  @signature {[:number, :integer], :number}
  @signature {[:integer, :number], :number}
  def add(a, b) do
    a + b
  end

  @doc """
    Subtract two values
  """
  @label "Sub"
  @short "-"
  @signature {[:integer, :integer], :number}
  @signature {[:number, :number], :number}
  @signature {[:number, :integer], :number}
  @signature {[:integer, :number], :number}
  def sub(a, b) do
    a - b
  end

  @doc """
    Multiply two values
  """
  @label "Mult"
  @short "×"
  @signature {[:integer, :integer], :number}
  @signature {[:number, :number], :number}
  @signature {[:number, :integer], :number}
  @signature {[:integer, :number], :number}
  def mult(a, b) do
    a * b
  end

  @doc """
    Divide two values
  """
  @label "Div"
  @short "÷"
  @signature {[:integer, :integer], :number}
  @signature {[:number, :number], :number}
  @signature {[:number, :integer], :number}
  @signature {[:integer, :number], :number}
  def div(a, b) do
    a / b
  end

  @doc """
    Check if a contains b.

    If a is a string, then check if b is a substring of a
  """
  @label "Contains"
  @short "∋"
  @signature {[:"integer[]", :integer], :boolean}
  @signature {[:"number[]", :number], :boolean}
  @signature {[:"string[]", :string], :boolean}
  @signature {[:"date[]", :date], :boolean}
  @signature {[:"datetime[]", :datetime], :boolean}
  @signature {[:string, :string], :boolean}
  def contains(list, el) when is_list(list) do
    el in list
  end

  # TODO case insensitive contains? split functions for string?
  def contains(str, el) when is_binary(str) do
    String.contains?(str, to_string(el))
  end

  @doc """
    Calculate age in years given a birthdate
  """
  @label "Age"
  @short "AGE()"
  @signature {[:date], :integer}
  def age(birthdate) do
    Timex.diff(NaiveDateTime.utc_now(), birthdate, :years)
  end

  @doc """
    Whether a duration in days is elapsed since a given date.
  """
  @label "Elapsed"
  @short "ELAPSED()"
  @signature {[:date, :integer], :integer}
  def elapsed(start_date, duration) do
    Timex.diff(NaiveDateTime.utc_now(), start_date, :days) > duration
  end

  @doc """
    Get the current time
  """
  @label "Now"
  @short "NOW()"
  @signature {[], :datetime}
  def now() do
    NaiveDateTime.utc_now()
  end
end
