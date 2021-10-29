defmodule VacEngine.Processor.LibraryTest do
  use ExUnit.Case

  import Kernel, except: [is_nil: 1, not: 1]
  import VacEngine.Processor.Library
  alias VacEngine.Processor.Library.Functions
  import VacEngine.Processor.Library.Functions

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
    assert not 5 == false
    assert not nil == true
    assert not false == true
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

  test "contains(list, number)" do
    assert has_function?(:contains, 2)
    assert contains([1, 2, 3], 4) == false
    assert contains([1, 4, 3], 4) == true
    assert contains(nil, 4) == nil
  end

  test "contains(string, number)" do
    assert contains("44", 4) == true
    assert contains("23", 4) == false
  end

  test "contains(string, string)" do
    assert contains("44", "4") == true
    assert contains("23", "4") == false
  end

  test "age(date)" do
    assert has_function?(:age, 1)
    assert age(nil) == nil

    assert age(Timex.parse!("1980-03-04", "{ISOdate}")) ==
             Fixtures.Helpers.age("1980-03-04")
  end

  test "candidates" do
    assert [
             %{
               label: "Contains",
               name: :contains,
               short: "∋",
               signatures: [{[:string, :string], :boolean}]
             },
             %{
               label: "Equals to",
               name: :eq,
               short: "=",
               signatures: [{[:string, :string], :boolean}]
             },
             %{
               label: "Not equal to",
               name: :neq,
               short: "≠",
               signatures: [{[:string, :string], :boolean}]
             }
           ] == candidates([:string, :string])

    assert [
             %{
               label: "Add",
               name: :add,
               short: "+",
               signatures: [
                 {[:integer, :number], :number},
                 {[:integer, :integer], :number}
               ]
             }
           ] == func_candidates(:add, [:integer])

    assert [] == func_candidates(:non_existing, [:any])
  end
end
