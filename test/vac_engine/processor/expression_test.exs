defmodule VacEngine.Processor.ExpressionTest do
  use ExUnit.Case

  alias VacEngine.Processor.Expression

  @expression %{
    elixir: %{
      ok: [
        {quote(do: gt(4, a)), {:gt, [4, "a"]}},
        {quote(do: gt(4, 5)), {:gt, [4, 5]}},
        {quote(do: lt(add(@a, 5), 8)), {:lt, [{:add, [{:var, ["a"]}, 5]}, 8]}}
      ],
      error: [
        {quote(do: File.read("/")), "invalid expression"},
        {quote(do: ggt(4, 5)), "undefined function ggt/2"},
        {quote(do: gt(llt(1, 2), 5)), "undefined function llt/2"},
      ]
    },
    json: %{
      ok: [
        {["gt", [4, "a"]], {:gt, [4, "a"]}},
        {["lt", [["add", ["a", 5]], 8]], {:lt, [{:add, ["a", 5]}, 8]}}
      ],
      error: [
        {["ggt", [4, "a"]], "undefined function ggt/2"},
        {%{"key" => "val"}, "invalid expression"},
      ]
    }
  }

  test "expression conversions" do
    for {_name, val} <- @expression do
      for {from, to} <- val.ok do
        assert {:ok, expr} = Expression.new(from)
        assert expr.ast == to
      end
      for {from, err} <- val.error do
        assert {:error, ^err} = Expression.new(from)
      end
    end
  end
end
