defmodule VacEngine.Processor.ExpressionTest do
  use ExUnit.Case

  alias VacEngine.Processor.Expression

  @elixir_expressions %{
    ok: [
      {quote(do: gt(4, a)), {:gt, [], [4, "a"]}},
      {quote(do: gt(4, 5)), {:gt, [], [4, 5]}},
      {quote(do: lt(add(@a, 5), 8)),
       {:lt, [], [{:add, [], [{:var, [], ["a"]}, 5]}, 8]}}
    ],
    error: [
      {quote(do: File.read("/")), "invalid expression"},
      {quote(do: ggt(4, 5)), "undefined function ggt/2"},
      {quote(do: gt(llt(1, 2), 5)), "undefined function llt/2"}
    ]
  }
  @json_expressions %{
    ok: [
      {%{"l" => "gt", "r" => [4, "a"], "m" => %{}}, {:gt, [], [4, "a"]}},
      {%{
         "l" => "lt",
         "m" => %{"signature" => [["integer", "integer"], "boolean"]},
         "r" => [%{"l" => "add", "r" => ["a", 5], "m" => %{}}, 8]
       },
       {:lt, [signature: {{:integer, :integer}, :boolean}],
        [{:add, [], ["a", 5]}, 8]}}
    ],
    error: [
      {%{"l" => "ggt", "r" => [4, "a"]}, "undefined function ggt/2"},
      {%{"key" => "val"}, "invalid expression"}
    ]
  }

  test "elixir expression conversions" do
    for {from, to} <- @elixir_expressions.ok do
      assert {:ok, expr} = Expression.new(from)
      assert expr.ast == to
    end

    for {from, expected_err} <- @elixir_expressions.error do
      assert {:error, actual_err} = Expression.new(from)
      assert actual_err == expected_err
    end
  end

  test "json expression conversions" do
    for {from, to} <- @json_expressions.ok do
      assert {:ok, expr} = Expression.deserialize(from)
      assert expr.ast == to
      assert {:ok, json} = Expression.serialize(expr)
      assert json == from
    end

    for {from, expected_err} <- @json_expressions.error do
      assert {:error, actual_err} = Expression.deserialize(from)
      assert actual_err == expected_err
    end
  end
end
