defmodule VacEngine.Processor.Library.Functions do
  use VacEngine.Processor.Library.Define

  import Kernel, except: [is_nil: 1, not: 1]
  alias Kernel, as: K

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
  @signature {[:boolean], :boolean}
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
  def not nil, do: true
  def not false, do: true
  def not _, do: false

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
  def eq(a, b) when K.is_nil(a) or K.is_nil(b), do: nil

  def eq(a, b) do
    a == b
  end

  @doc false
  def neq(a, b) when is_float(a) or is_float(b) do
    throw({:argument_error, "neq cannot be used for non integer"})
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
  def neq(a, b) when K.is_nil(a) or K.is_nil(b), do: nil

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
  def gt(a, b) when K.is_nil(a) or K.is_nil(b), do: nil

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
  def gte(a, b) when K.is_nil(a) or K.is_nil(b), do: nil

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
  def lt(a, b) when K.is_nil(a) or K.is_nil(b), do: nil

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
  def lte(a, b) when K.is_nil(a) or K.is_nil(b), do: nil

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
  def add(a, b) when K.is_nil(a) or K.is_nil(b), do: nil

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
  def sub(a, b) when K.is_nil(a) or K.is_nil(b), do: nil

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
  def mult(a, b) when K.is_nil(a) or K.is_nil(b), do: nil

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
  def div(a, b) when K.is_nil(a) or K.is_nil(b), do: nil

  def div(a, b) do
    a / b
  end

  @doc """
    Check if a contains b.

    If a is a string, then check if b is a substring of a (case sensitive)
  """
  @label "Contains"
  @short "∋"
  @signature {[:"integer[]", :integer], :boolean}
  @signature {[:"number[]", :number], :boolean}
  @signature {[:"string[]", :string], :boolean}
  @signature {[:"date[]", :date], :boolean}
  @signature {[:"datetime[]", :datetime], :boolean}
  @signature {[:string, :string], :boolean}
  def contains(list, el) when K.is_nil(list) or K.is_nil(el), do: nil

  def contains(list, el) when is_list(list) do
    el in list
  end

  def contains(str, el) when is_binary(str) do
    String.contains?(str, to_string(el))
  end


  @doc """
    Boolean AND
  """
  @label "And"
  @short "AND()"
  @signature {[:boolean, :boolean], :boolean}
  def andz(nil, nil), do: nil
  def andz(a, nil), do: a
  def andz(nil, b), do: b
  def andz(a, b) do
    a && b
  end


  @doc """
    Boolean OR
  """
  @label "Or"
  @short "OR()"
  @signature {[:boolean, :boolean], :boolean}
  def orz(nil, nil), do: nil
  def orz(a, nil), do: a
  def orz(nil, b), do: b
  def orz(a, b) do
    a || b
  end



  @doc """
    Get the current time
  """
  @label "Now"
  @short "NOW()"
  @signature {[], :datetime}
  def now() do
    # TODO bake now() to avoid having side effects within the blueprint
    NaiveDateTime.utc_now()
  end

  @doc """
    Calculate age in years given a birthdate

    Value returned in years.
  """
  @label "Age"
  @short "AGE()"
  @signature {[:date], :integer}
  def age(nil), do: nil

  def age(birthdate) do
    Timex.diff(NaiveDateTime.utc_now(), birthdate, :years)
  end

  @doc """
    Return earliest date
  """
  @label "Earliest"
  @short "EARLIEST()"
  @signature {[:date, :date], :date}
  @signature {[:datetime, :datetime], :datetime}
  def earliest(a, b) when K.is_nil(a) and K.is_nil(b), do: nil

  def earliest(a, b) when K.is_nil(a), do: b
  def earliest(a, b) when K.is_nil(b), do: a

  def earliest(a, b) do
    case Date.compare(a, b) do
      :lt -> a
      _ -> b
    end
  end

  @doc """
    Return latest date
  """
  @label "Latest"
  @short "LATEST()"
  @signature {[:date, :date], :date}
  @signature {[:datetime, :datetime], :datetime}
  def latest(a, b) when K.is_nil(a) and K.is_nil(b), do: nil

  def latest(a, b) when K.is_nil(a), do: b
  def latest(a, b) when K.is_nil(b), do: a

  def latest(a, b) do
    case Date.compare(a, b) do
      :lt -> b
      _ -> a
    end
  end

  @doc """
    Add years to date
  """
  @label "Add years"
  @short "ADD_YEARS()"
  @signature {[:date, :integer], :date}
  @signature {[:datetime, :integer], :datetime}
  def add_years(date, years) when K.is_nil(date) or K.is_nil(years), do: nil

  def add_years(date, years) do
    Timex.shift(date, years: years)
  end

  @doc """
    Add months to date
  """
  @label "Add months"
  @short "ADD_MONTHS()"
  @signature {[:date, :integer], :date}
  @signature {[:datetime, :integer], :datetime}
  def add_months(date, months) when K.is_nil(date) or K.is_nil(months), do: nil

  def add_months(date, months) do
    Timex.shift(date, months: months)
  end

  @doc """
    Add weeks to date
  """
  @label "Add weeks"
  @short "ADD_WEEKS()"
  @signature {[:date, :integer], :date}
  @signature {[:datetime, :integer], :datetime}
  def add_weeks(date, weeks) when K.is_nil(date) or K.is_nil(weeks), do: nil

  def add_weeks(date, weeks) do
    Timex.shift(date, weeks: weeks)
  end

  @doc """
    Add days to date
  """
  @label "Add days"
  @short "ADD_DAYS()"
  @signature {[:date, :integer], :date}
  @signature {[:datetime, :integer], :datetime}
  def add_days(date, days) when K.is_nil(date) or K.is_nil(days), do: nil

  def add_days(date, days) do
    Timex.shift(date, days: days)
  end

  @doc """
    Add hours to date
  """
  @label "Add hours"
  @short "ADD_HOURS()"
  @signature {[:datetime, :integer], :datetime}
  def add_hours(date, hours) when K.is_nil(date) or K.is_nil(hours), do: nil

  def add_hours(date, hours) do
    Timex.shift(date, hours: hours)
  end

  @doc """
    Add minutes to date
  """
  @label "Add minutes"
  @short "ADD_MINUTES()"
  @signature {[:datetime, :integer], :datetime}
  def add_minutes(date, minutes) when K.is_nil(date) or K.is_nil(minutes),
    do: nil

  def add_minutes(date, minutes) do
    Timex.shift(date, minutes: minutes)
  end

  @doc """
    Add seconds to date
  """
  @label "Add seconds"
  @short "ADD_SECONDS()"
  @signature {[:datetime, :integer], :datetime}
  def add_seconds(date, seconds) when K.is_nil(date) or K.is_nil(seconds),
    do: nil

  def add_seconds(date, seconds) do
    Timex.shift(date, seconds: seconds)
  end

  @doc """
    Return the year difference between two dates

    Always return a positive  number.
  """
  @label "Years between"
  @short "YEARS_BETWEEN()"
  @signature {[:date, :date], :integer}
  @signature {[:datetime, :datetime], :integer}
  def years_between(a, b) when K.is_nil(a) or K.is_nil(b), do: nil

  def years_between(a, b) do
    Timex.diff(a, b, :years) |> abs()
  end

  @doc """
    Return the month difference between two dates

    Always return a positive  number.
  """
  @label "Months between"
  @short "MONTHS_BETWEEN()"
  @signature {[:date, :date], :integer}
  @signature {[:datetime, :datetime], :integer}
  def months_between(a, b) when K.is_nil(a) or K.is_nil(b), do: nil

  def months_between(a, b) do
    Timex.diff(a, b, :months) |> abs()
  end

  @doc """
    Return the week difference between two dates

    Always return a positive  number.
  """
  @label "Weeks between"
  @short "WEEKS_BETWEEN()"
  @signature {[:date, :date], :integer}
  @signature {[:datetime, :datetime], :integer}
  def weeks_between(a, b) when K.is_nil(a) or K.is_nil(b), do: nil

  def weeks_between(a, b) do
    Timex.diff(a, b, :weeks) |> abs()
  end

  @doc """
    Return the day difference between two dates

    Always return a positive  number.
  """
  @label "Days between"
  @short "DAYS_BETWEEN()"
  @signature {[:date, :date], :integer}
  @signature {[:datetime, :datetime], :integer}
  def days_between(a, b) when K.is_nil(a) or K.is_nil(b), do: nil

  def days_between(a, b) do
    Timex.diff(a, b, :days) |> abs()
  end

  @doc """
    Return the hour difference between two dates

    Always return a positive  number.
  """
  @label "Hours between"
  @short "HOURS_BETWEEN()"
  @signature {[:date, :date], :integer}
  @signature {[:datetime, :datetime], :integer}
  def hours_between(a, b) when K.is_nil(a) or K.is_nil(b), do: nil

  def hours_between(a, b) do
    Timex.diff(a, b, :hours) |> abs()
  end

  @doc """
    Return the minute difference between two dates

    Always return a positive  number.
  """
  @label "Minutes between"
  @short "MINUTES_BETWEEN()"
  @signature {[:date, :date], :integer}
  @signature {[:datetime, :datetime], :integer}
  def minutes_between(a, b) when K.is_nil(a) or K.is_nil(b), do: nil

  def minutes_between(a, b) do
    Timex.diff(a, b, :minutes) |> abs()
  end

  @doc """
    Return the second difference between two dates

    Always return a positive  number.
  """
  @label "Seconds between"
  @short "SECONDS_BETWEEN()"
  @signature {[:date, :date], :integer}
  @signature {[:datetime, :datetime], :integer}
  def seconds_between(a, b) when K.is_nil(a) or K.is_nil(b), do: nil

  def seconds_between(a, b) do
    Timex.diff(a, b, :seconds) |> abs()
  end
end
