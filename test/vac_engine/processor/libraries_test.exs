defmodule VacEngine.Processor.LibrariesTest do
  use ExUnit.Case

  alias VacEngine.Processor.Compiler.Libraries
  import VacEngine.Processor.Compiler.Libraries

  test "is_true(bool)" do
    assert is_true(true) == true
    assert is_true(1) == false
    assert is_true(false) == false
  end

  test "is_false(bool)" do
    assert is_false(false) == true
    assert is_false(0) == false
    assert is_false(true) == false
  end

  test "not(bool)" do
    assert Libraries.not(true) == false
    assert Libraries.not(false) == true
  end

  test "not(any)" do
    assert_raise RuntimeError, fn -> Libraries.not("a") end
    assert_raise RuntimeError, fn -> Libraries.not(1) end
    assert_raise RuntimeError, fn -> Libraries.not(0) end
  end

  test "eq(bool, bool)" do
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
  end

  test "eq(number, number)" do
    assert_raise RuntimeError, fn -> eq(5.0, 5) end
    assert_raise RuntimeError, fn -> eq(5, 5.0) end
    assert_raise RuntimeError, fn -> eq(5.0, 5.0) end
  end

  test "neq(bool, bool)" do
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
  end

  test "neq(number, number)" do
    assert_raise RuntimeError, fn -> neq(5.0, 5) end
    assert_raise RuntimeError, fn -> neq(5, 5.0) end
    assert_raise RuntimeError, fn -> neq(5.0, 5.0) end
  end

  test "gt(bool, bool)" do
    assert gt(true, false) == true
    assert gt(true, true) == false
    assert gt(false, false) == false
    assert gt(false, true) == false
  end

  test "gt(int, int)" do
    assert gt(5, 4) == true
    assert gt(4, 4) == false
    assert gt(4, 5) == false
  end

  test "gte(int, int)" do
    assert gte(5, 4) == true
    assert gte(4, 4) == true
    assert gte(4, 5) == false
  end

  test "gt(number, number)" do
    assert gt(5, 4.0) == true
    assert gt(5.0, 4.0) == true
    assert gt(4, 4.0) == false
    assert gt(4.0, 5) == false
  end

  test "lt(bool, bool)" do
    assert lt(true, false) == false
    assert lt(true, true) == false
    assert lt(false, false) == false
    assert lt(false, true) == true
  end

  test "lt(int, int)" do
    assert lt(5, 4) == false
    assert lt(4, 4) == false
    assert lt(4, 5) == true
  end

  test "lte(int, int)" do
    assert lte(5, 4) == false
    assert lte(4, 4) == true
    assert lte(4, 5) == true
  end

  test "lt(number, number)" do
    assert lt(5, 4.0) == false
    assert lt(5.0, 4.0) == false
    assert lt(4, 4.0) == false
    assert lt(4.0, 5) == true
  end

  test "add(number, number)" do
    assert add(5, 4) == 9
    assert add(4, 4) == 8
    assert add(4.5, 3) == 7.5
  end

  test "sub(number, number)" do
    assert sub(5, 4) == 1
    assert sub(4, 4) == 0
    assert sub(4.5, 3) == 1.5
  end

  test "mult(number, number)" do
    assert mult(5, 4) == 20
    assert mult(4, 4) == 16
    assert mult(4.5, 3) == 13.5
  end

  test "div(number, number)" do
    assert Libraries.div(5, 4) == 1.25
    assert Libraries.div(4, 4) == 1
    assert Libraries.div(4.5, 3) == 1.5
  end

  test "contains(list, number)" do
    assert contains([1, 2, 3], 4) == false
    assert contains([1, 4, 3], 4) == true
  end

  test "contains(string, number)" do
    assert contains("44", 4) == true
    assert contains("23", 4) == false
  end

  test "contains(string, string)" do
    assert contains("44", "4") == true
    assert contains("23", "4") == false
  end


end
