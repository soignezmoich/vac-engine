defmodule VacEngine.Processor.Library.Functions do
  @moduledoc """
  Actual blueprint expression functions
  """

  use VacEngine.Processor.Library.Define

  @doc """
  Check if struct is date
  """
  defmacro is_date(a) do
    quote do
      is_struct(unquote(a), NaiveDateTime) or is_struct(unquote(a), Date) or
        is_struct(unquote(a), DateTime)
    end
  end

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
  @rename :not
  @signature {[:boolean], :boolean}
  def not_(nil), do: true
  def not_(false), do: true
  def not_(_), do: false

  @doc """
    Boolean AND
  """
  @label "And"
  @short "AND()"
  @rename :and
  @signature {[:boolean, :boolean], :boolean}
  def and_(nil, nil), do: nil
  def and_(a, nil), do: a
  def and_(nil, b), do: b

  def and_(a, b) do
    a && b
  end

  @doc """
    Boolean OR
  """
  @label "Or"
  @short "OR()"
  @rename :or
  @signature {[:boolean, :boolean], :boolean}
  def or_(nil, nil), do: nil
  def or_(a, nil), do: a
  def or_(nil, b), do: b

  def or_(a, b) do
    a || b
  end

  @doc """
    Check if variable is nil

    Returns false only for nil
  """
  @label "Is nil"
  @short "NIL"
  @rename :is_nil
  @signature {[:any], :boolean}
  def is_nil_(nil), do: true
  def is_nil_(_), do: false

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
  def eq(a, b) when is_nil(a) or is_nil(b), do: nil

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
  def neq(a, b) when is_nil(a) or is_nil(b), do: nil

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
  def gt(a, b) when is_nil(a) or is_nil(b), do: nil

  def gt(a, b) when is_date(a) and is_date(b) do
    Timex.after?(a, b)
  end

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
  def gte(a, b) when is_nil(a) or is_nil(b), do: nil

  def gte(a, b) when is_date(a) and is_date(b) do
    Timex.compare(a, b) >= 0
  end

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
  def lt(a, b) when is_nil(a) or is_nil(b), do: nil

  def lt(a, b) when is_date(a) and is_date(b) do
    Timex.before?(a, b)
  end

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
  def lte(a, b) when is_nil(a) or is_nil(b), do: nil

  def lte(a, b) when is_date(a) and is_date(b) do
    Timex.compare(a, b) <= 0
  end

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
  def add(a, b) when is_nil(a) or is_nil(b), do: nil

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
  def sub(a, b) when is_nil(a) or is_nil(b), do: nil

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
  def mult(a, b) when is_nil(a) or is_nil(b), do: nil

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
  def div(a, b) when is_nil(a) or is_nil(b), do: nil

  def div(a, b) do
    a / b
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
  def earliest(a, b) when is_nil(a) and is_nil(b), do: nil

  def earliest(a, b) when is_nil(a) and is_date(b), do: b
  def earliest(a, b) when is_nil(b) and is_date(a), do: a

  def earliest(a, b) when is_date(a) and is_date(b) do
    if Timex.before?(a, b) do
      a
    else
      b
    end
  end

  @doc """
    Return latest date
  """
  @label "Earliest"
  @short "EARLIEST()"
  @signature {[:date, :date, :date], :date}
  @signature {[:datetime, :datetime, :datetime], :datetime}
  def earliest(nil, nil, nil), do: nil

  def earliest(a, b, nil), do: earliest(a, b)
  def earliest(a, nil, b), do: earliest(a, b)
  def earliest(nil, a, b), do: earliest(a, b)

  def earliest(a, b, c) when is_date(a) and is_date(b) and is_date(c) do
    [a, b, c]
    |> Enum.sort(&(Timex.compare(&1, &2) > 0))
    |> List.last()
  end

  @doc """
    Return latest date
  """
  @label "Latest"
  @short "LATEST()"
  @signature {[:date, :date], :date}
  @signature {[:datetime, :datetime], :datetime}
  def latest(a, b) when is_nil(a) and is_nil(b), do: nil

  def latest(a, b) when is_nil(a) and is_date(b), do: b
  def latest(a, b) when is_nil(b) and is_date(a), do: a

  def latest(a, b) when is_date(a) and is_date(b) do
    if Timex.after?(a, b) do
      a
    else
      b
    end
  end

  @doc """
    Return latest date
  """
  @label "Latest"
  @short "LATEST()"
  @signature {[:date, :date, :date], :date}
  @signature {[:datetime, :datetime, :datetime], :datetime}
  def latest(nil, nil, nil), do: nil

  def latest(a, b, nil), do: latest(a, b)
  def latest(a, nil, b), do: latest(a, b)
  def latest(nil, a, b), do: latest(a, b)

  def latest(a, b, c) when is_date(a) and is_date(b) and is_date(c) do
    [a, b, c]
    |> Enum.sort(&(Timex.compare(&1, &2) > 0))
    |> List.first()
  end

  @doc """
    Add years to date
  """
  @label "Add years"
  @short "ADD_YEARS()"
  @signature {[:date, :integer], :date}
  @signature {[:datetime, :integer], :datetime}
  def add_years(date, years) when is_nil(date) or is_nil(years), do: nil

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
  def add_months(date, months) when is_nil(date) or is_nil(months), do: nil

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
  def add_weeks(date, weeks) when is_nil(date) or is_nil(weeks), do: nil

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
  def add_days(date, days) when is_nil(date) or is_nil(days), do: nil

  def add_days(date, days) do
    Timex.shift(date, days: days)
  end

  @doc """
    Add hours to date
  """
  @label "Add hours"
  @short "ADD_HOURS()"
  @signature {[:datetime, :integer], :datetime}
  def add_hours(date, hours) when is_nil(date) or is_nil(hours), do: nil

  def add_hours(date, hours) do
    Timex.shift(date, hours: hours)
  end

  @doc """
    Add minutes to date
  """
  @label "Add minutes"
  @short "ADD_MINUTES()"
  @signature {[:datetime, :integer], :datetime}
  def add_minutes(date, minutes) when is_nil(date) or is_nil(minutes),
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
  def add_seconds(date, seconds) when is_nil(date) or is_nil(seconds),
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
  def years_between(a, b) when is_nil(a) or is_nil(b), do: nil

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
  def months_between(a, b) when is_nil(a) or is_nil(b), do: nil

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
  def weeks_between(a, b) when is_nil(a) or is_nil(b), do: nil

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
  def days_between(a, b) when is_nil(a) or is_nil(b), do: nil

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
  def hours_between(a, b) when is_nil(a) or is_nil(b), do: nil

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
  def minutes_between(a, b) when is_nil(a) or is_nil(b), do: nil

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
  def seconds_between(a, b) when is_nil(a) or is_nil(b), do: nil

  def seconds_between(a, b) do
    Timex.diff(a, b, :seconds) |> abs()
  end
end
