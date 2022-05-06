defmodule VacEngine.Processor.CompilerTest do
  @moduledoc false

  use VacEngine.DataCase

  alias VacEngine.Processor.Compiler
  alias VacEngine.Processor.Expression

  defmacro assert_expr(status, result, binding, do: block) do
    quote bind_quoted: [
            result: result,
            status: status,
            block: Macro.escape(block),
            binding: binding
          ] do
      binding = smap(binding)
      assert {^status, ^result} = Compiler.eval_expression(block, binding)
    end
  end

  defmacro assert_expr_ok(result, binding, do: block) do
    quote do
      assert_expr(:ok, unquote(result), unquote(binding), do: unquote(block))
    end
  end

  defmacro assert_expr_err(result, binding, do: block) do
    quote do
      assert_expr(:error, unquote(result), unquote(binding), do: unquote(block))
    end
  end

  test "expressions ok" do
    assert_expr_ok(true, %{age: 18}) do
      gt(add(4, @age), 20)
    end

    assert_expr_ok(22, %{age: 18}) do
      add(4, @age)
    end

    assert_expr_ok(22.0, %{age: 22}) do
      div(mult(4, @age), 4)
    end
  end

  test "expressions error" do
    assert_expr_err("invalid_path: variable age not found", %{}) do
      add(4, @age)
    end

    assert_expr_err("undefined function thingy/1", %{}) do
      thingy(4)
    end

    assert_expr_err("undefined function thingy/3", %{}) do
      thingy(1, 2, 3)
    end
  end

  test "invalid call" do
    assert {:error, "invalid_var: invalid call of var/1"} ==
             Compiler.eval_expression(%Expression{ast: {:var, [], []}})
  end
end
