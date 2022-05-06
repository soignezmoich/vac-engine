defmodule VacEngine.Processor.LibraryTest do
  @moduledoc false

  use ExUnit.Case

  import VacEngine.Processor.Library
  alias VacEngine.Processor.Library.Functions
  import VacEngine.Processor.Library.Functions

  test "var(name)" do
    assert has_function?(:var, 1)
    assert_raise RuntimeError, fn -> var(true) end
  end

  test "is_true(bool)" do
    assert has_function?(:is_true, 1)
    assert is_true(true) == true
    assert is_true(1) == false
    assert is_true(false) == false
    assert is_true(nil) == false
  end

  test "is_false(bool)" do
    assert has_function?(:is_false, 1)
    assert is_false(false) == true
    assert is_false(nil) == true
    assert is_false(0) == false
    assert is_false(true) == false
  end

  test "not(any)" do
    assert has_function?(:not, 1)
    assert not_(5) == false
    assert not_(nil) == true
    assert not_(false) == true
  end

  test "and(any)" do
    assert has_function?(:and, 2)
    assert and_(false, false) == false
    assert and_(true, false) == false
    assert and_(true, true) == true
    assert and_(nil, true) == true
    assert and_(true, nil) == true
    assert and_(nil, nil) == nil
  end

  test "or(any)" do
    assert has_function?(:or, 2)
    assert or_(false, false) == false
    assert or_(true, false) == true
    assert or_(true, true) == true
    assert or_(nil, true) == true
    assert or_(true, nil) == true
    assert or_(nil, nil) == nil
  end

  test "eq(bool, bool)" do
    assert has_function?(:eq, 2)
    assert eq(true, true) == true
    assert eq(false, false) == true
    assert eq(true, false) == false
    assert eq(true, 1) == false
    assert eq(false, 0) == false
  end

  test "eq(int, int)" do
    assert eq(5, 5) == true
    assert eq(4, 6) == false
    assert eq(4, 5) == false
    assert eq(nil, 5) == nil
  end

  test "eq(number, number)" do
    assert catch_throw(eq(5.0, 5)) ==
             {:argument_error, "eq cannot be used for non integer"}

    assert catch_throw(eq(5, 5.0)) ==
             {:argument_error, "eq cannot be used for non integer"}

    assert catch_throw(eq(5.0, 5.0)) ==
             {:argument_error, "eq cannot be used for non integer"}
  end

  test "neq(bool, bool)" do
    assert has_function?(:neq, 2)
    assert neq(true, true) == false
    assert neq(false, false) == false
    assert neq(true, false) == true
    assert neq(true, 1) == true
    assert neq(false, 0) == true
  end

  test "neq(int, int)" do
    assert neq(5, 5) == false
    assert neq(4, 6) == true
    assert neq(4, 5) == true
    assert neq(nil, 5) == nil
  end

  test "neq(number, number)" do
    assert catch_throw(neq(5.0, 5)) ==
             {:argument_error, "neq cannot be used for non integer"}

    assert catch_throw(neq(5, 5.0)) ==
             {:argument_error, "neq cannot be used for non integer"}

    assert catch_throw(neq(5.0, 5.0)) ==
             {:argument_error, "neq cannot be used for non integer"}
  end

  test "gt(bool, bool)" do
    assert has_function?(:gt, 2)
    assert gt(true, false) == true
    assert gt(true, true) == false
    assert gt(false, false) == false
    assert gt(false, true) == false
    assert gt(nil, true) == nil
  end

  test "gt(int, int)" do
    assert gt(5, 4) == true
    assert gt(4, 4) == false
    assert gt(4, 5) == false
  end

  test "gte(int, int)" do
    assert has_function?(:gte, 2)
    assert gte(5, 4) == true
    assert gte(4, 4) == true
    assert gte(4, 5) == false
  end

  test "gt(number, number)" do
    assert has_function?(:gt, 2)
    assert gt(5, 4.0) == true
    assert gt(5.0, 4.0) == true
    assert gt(4, 4.0) == false
    assert gt(4.0, 5) == false
    assert gt(nil, 5) == nil
  end

  test "lt(bool, bool)" do
    assert has_function?(:lt, 2)
    assert lt(true, false) == false
    assert lt(true, true) == false
    assert lt(false, false) == false
    assert lt(false, true) == true
  end

  test "lt(int, int)" do
    assert lt(5, 4) == false
    assert lt(4, 4) == false
    assert lt(4, 5) == true
    assert lt(nil, 5) == nil
  end

  test "lte(int, int)" do
    assert has_function?(:lte, 2)
    assert lte(5, 4) == false
    assert lte(4, 4) == true
    assert lte(4, 5) == true
    assert lte(4, nil) == nil
  end

  test "lt(number, number)" do
    assert lt(5, 4.0) == false
    assert lt(5.0, 4.0) == false
    assert lt(4, 4.0) == false
    assert lt(4.0, 5) == true
    assert lt(4.0, nil) == nil
  end

  test "add(number, number)" do
    assert has_function?(:add, 2)
    assert add(5, 4) == 9
    assert add(4, 4) == 8
    assert add(4.5, 3) == 7.5
    assert add(4.5, nil) == nil
  end

  test "sub(number, number)" do
    assert has_function?(:sub, 2)
    assert sub(5, 4) == 1
    assert sub(4, 4) == 0
    assert sub(4.5, 3) == 1.5
    assert sub(4.5, nil) == nil
  end

  test "mult(number, number)" do
    assert has_function?(:mult, 2)
    assert mult(5, 4) == 20
    assert mult(4, 4) == 16
    assert mult(4.5, 3) == 13.5
    assert mult(4.5, nil) == nil
  end

  test "div(number, number)" do
    assert has_function?(:div, 2)
    assert Functions.div(5, 4) == 1.25
    assert Functions.div(4, 4) == 1
    assert Functions.div(4.5, 3) == 1.5
    assert Functions.div(nil, 3) == nil
  end

  test "age(date)" do
    assert has_function?(:age, 1)

    assert_raise RuntimeError, fn -> age(nil) end

    now = Timex.parse!("2021-03-04", "{ISOdate}")
    birth = Timex.parse!("1980-03-04", "{ISOdate}")
    assert age_(%{env: %{now: now}}, birth) == 41
  end

  test "now()" do
    assert has_function?(:now, 0)
    assert_raise RuntimeError, fn -> now() end
  end

  test "earliest()" do
    a = Timex.parse!("1980-06-30", "{ISOdate}")
    b = Timex.parse!("1980-07-01", "{ISOdate}")
    c = Timex.parse!("1990-01-02", "{ISOdate}")
    assert has_function?(:earliest, 2)
    assert earliest(nil, nil) == nil
    assert earliest(a, nil) == a
    assert earliest(nil, a) == a
    assert earliest(a, b) == a
    assert earliest(b, a) == a

    assert has_function?(:earliest, 3)
    assert earliest(nil, nil, nil) == nil
    assert earliest(a, nil, nil) == a
    assert earliest(a, b, nil) == a
    assert earliest(a, nil, b) == a
    assert earliest(nil, b, a) == a
    assert earliest(a, b, c) == a
    assert earliest(a, a, c) == a
    assert earliest(c, a, b) == a
    assert earliest(a, c, b) == a
  end

  test "comparison date" do
    a = Timex.parse!("1980-06-30", "{ISOdate}")
    b = Timex.parse!("1980-07-01", "{ISOdate}")
    c = Timex.parse!("1980-07-01", "{ISOdate}")
    assert lt(a, b)
    assert lte(a, b)
    assert lte(a, c)
    assert lte(b, c)
    assert eq(c, c)
    assert gt(b, a)
    assert gte(b, a)
    assert gte(c, a)
    assert gte(b, c)
    assert neq(a, c)
  end

  test "latest()" do
    a = Timex.parse!("1980-06-30", "{ISOdate}")
    b = Timex.parse!("1980-07-01", "{ISOdate}")
    c = Timex.parse!("1984-07-01", "{ISOdate}")
    assert has_function?(:latest, 2)
    assert latest(nil, nil) == nil
    assert latest(a, nil) == a
    assert latest(nil, a) == a
    assert latest(a, b) == b
    assert latest(b, a) == b

    assert has_function?(:latest, 3)
    assert latest(nil, nil, nil) == nil
    assert latest(a, nil, nil) == a
    assert latest(a, b, nil) == b
    assert latest(a, nil, b) == b
    assert latest(nil, b, a) == b
    assert latest(a, b, c) == c
    assert latest(a, a, c) == c
    assert latest(c, a, b) == c
    assert latest(a, c, b) == c
  end

  test "add_years()" do
    a = Timex.parse!("1980-03-04", "{ISOdate}")
    b = Timex.parse!("1985-03-04", "{ISOdate}")
    assert has_function?(:add_years, 2)
    assert add_years(nil, nil) == nil
    assert add_years(a, nil) == nil
    assert add_years(nil, 3) == nil
    assert add_years(a, 5) == b
  end

  test "add_months()" do
    a = Timex.parse!("1980-03-04", "{ISOdate}")
    b = Timex.parse!("1980-08-04", "{ISOdate}")
    assert has_function?(:add_months, 2)
    assert add_months(nil, nil) == nil
    assert add_months(a, nil) == nil
    assert add_months(nil, 3) == nil
    assert add_months(a, 5) == b
  end

  test "add_weeks()" do
    a = Timex.parse!("1980-04-08", "{ISOdate}")
    b = Timex.parse!("1980-05-13", "{ISOdate}")
    assert has_function?(:add_weeks, 2)
    assert add_weeks(nil, nil) == nil
    assert add_weeks(a, nil) == nil
    assert add_weeks(nil, 3) == nil
    assert add_weeks(a, 5) == b
  end

  test "add_days()" do
    a = Timex.parse!("1980-03-04", "{ISOdate}")
    b = Timex.parse!("1980-03-09", "{ISOdate}")
    assert has_function?(:add_days, 2)
    assert add_days(nil, nil) == nil
    assert add_days(a, nil) == nil
    assert add_days(nil, 3) == nil
    assert add_days(a, 5) == b
  end

  test "add_hours()" do
    a = Timex.parse!("1980-03-04 10:00", "{RFC3339}")
    b = Timex.parse!("1980-03-04 15:00", "{RFC3339}")
    assert has_function?(:add_hours, 2)
    assert add_hours(nil, nil) == nil
    assert add_hours(a, nil) == nil
    assert add_hours(nil, 3) == nil
    assert add_hours(a, 5) == b
  end

  test "add_minutes()" do
    a = Timex.parse!("1980-03-04 10:00", "{RFC3339}")
    b = Timex.parse!("1980-03-04 11:15", "{RFC3339}")
    assert has_function?(:add_minutes, 2)
    assert add_minutes(nil, nil) == nil
    assert add_minutes(a, nil) == nil
    assert add_minutes(nil, 3) == nil
    assert add_minutes(a, 75) == b
  end

  test "add_seconds()" do
    a = Timex.parse!("1980-03-04 10:00:04", "{RFC3339}")
    b = Timex.parse!("1980-03-04 10:01:49", "{RFC3339}")
    assert has_function?(:add_seconds, 2)
    assert add_seconds(nil, nil) == nil
    assert add_seconds(a, nil) == nil
    assert add_seconds(nil, 3) == nil
    assert add_seconds(a, 105) == b
  end

  test "years_between()" do
    a = Timex.parse!("1980-03-04", "{ISOdate}")
    b = Timex.parse!("1985-03-04", "{ISOdate}")
    assert has_function?(:years_between, 2)
    assert years_between(nil, nil) == nil
    assert years_between(a, nil) == nil
    assert years_between(nil, 3) == nil
    assert years_between(a, b) == 5
  end

  test "months_between()" do
    a = Timex.parse!("1980-03-04", "{ISOdate}")
    b = Timex.parse!("1985-08-04", "{ISOdate}")
    assert has_function?(:months_between, 2)
    assert months_between(nil, nil) == nil
    assert months_between(a, nil) == nil
    assert months_between(nil, 3) == nil
    assert months_between(a, b) == 65
  end

  test "weeks_between()" do
    a = Timex.parse!("1980-03-04", "{ISOdate}")
    b = Timex.parse!("1982-03-04", "{ISOdate}")
    assert has_function?(:weeks_between, 2)
    assert weeks_between(nil, nil) == nil
    assert weeks_between(a, nil) == nil
    assert weeks_between(nil, 3) == nil
    assert weeks_between(a, b) == 104
  end

  test "days_between()" do
    a = Timex.parse!("1980-03-04", "{ISOdate}")
    b = Timex.parse!("1980-08-04", "{ISOdate}")
    assert has_function?(:days_between, 2)
    assert days_between(nil, nil) == nil
    assert days_between(a, nil) == nil
    assert days_between(nil, 3) == nil
    assert days_between(a, b) == 153
  end

  test "hours_between()" do
    a = Timex.parse!("1980-03-04 10:00", "{RFC3339}")
    b = Timex.parse!("1980-03-04 13:00", "{RFC3339}")
    assert has_function?(:hours_between, 2)
    assert hours_between(nil, nil) == nil
    assert hours_between(a, nil) == nil
    assert hours_between(nil, 3) == nil
    assert hours_between(a, b) == 3
  end

  test "minutes_between()" do
    a = Timex.parse!("1980-03-04 10:00", "{RFC3339}")
    b = Timex.parse!("1980-03-04 13:41", "{RFC3339}")
    assert has_function?(:minutes_between, 2)
    assert minutes_between(nil, nil) == nil
    assert minutes_between(a, nil) == nil
    assert minutes_between(nil, 3) == nil
    assert minutes_between(a, b) == 221
  end

  test "seconds_between()" do
    a = Timex.parse!("1980-03-04 10:00:04", "{RFC3339}")
    b = Timex.parse!("1980-03-04 10:01:49", "{RFC3339}")
    assert has_function?(:seconds_between, 2)
    assert seconds_between(nil, nil) == nil
    assert seconds_between(a, nil) == nil
    assert seconds_between(nil, 3) == nil
    assert seconds_between(a, b) == 105
  end

  test "candidates" do
    assert candidates(%{name: :latest, arity: 2, arguments: [:date]})
           |> Enum.count() == 1

    assert candidates(%{name: "latest/3", arguments: [:date]}) |> Enum.count() ==
             1

    assert candidates(%{name: "latest", arguments: [:date]}) |> Enum.count() ==
             2

    assert [
             %{
               label: "Equals to",
               arity: 2,
               name: :eq,
               short: "=",
               name_arity: "eq/2",
               signatures: [{[:string, :string], :boolean}]
             },
             %{
               label: "Not equal to",
               arity: 2,
               name: :neq,
               short: "≠",
               name_arity: "neq/2",
               signatures: [{[:string, :string], :boolean}]
             }
           ] == candidates(%{arguments: [:string, :string]})

    assert [
             %{
               label: "Add",
               arity: 2,
               name: :add,
               short: "+",
               name_arity: "add/2",
               signatures: [
                 {[:integer, :number], :number},
                 {[:integer, :integer], :integer}
               ]
             }
           ] == candidates(%{name: :add, arguments: [:integer]})

    assert [] == candidates(%{name: :non_existing, arguments: [:any]})

    assert [
             %{
               label: "And",
               arity: 2,
               name: :and,
               short: "AND",
               name_arity: "and/2",
               signatures: [{[:boolean, :boolean], :boolean}]
             },
             %{
               label: "Equals to",
               arity: 2,
               name: :eq,
               short: "=",
               name_arity: "eq/2",
               signatures: [{[:boolean, :boolean], :boolean}]
             },
             %{
               label: "Not equal to",
               arity: 2,
               name: :neq,
               short: "≠",
               name_arity: "neq/2",
               signatures: [{[:boolean, :boolean], :boolean}]
             },
             %{
               label: "Or",
               arity: 2,
               name: :or,
               short: "OR",
               name_arity: "or/2",
               signatures: [{[:boolean, :boolean], :boolean}]
             }
           ] == candidates(%{arguments: [:boolean, :boolean]})
  end
end
