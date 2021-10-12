defmodule VacEngine.Processor.ExpressionTest do
  use ExUnit.Case

  alias VacEngine.Processor.Ast

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
       {:lt, [signature: {[:integer, :integer], :boolean}],
        [{:add, [], ["a", 5]}, 8]}}
    ],
    error: [
      {%{"l" => "ggt", "r" => [4, "a"]}, "undefined function ggt/2"},
      {%{"key" => "val"}, "invalid expression"}
    ]
  }

  test "elixir expression conversions" do
    for {from, to} <- @elixir_expressions.ok do
      assert {:ok, expr} = Ast.sanitize(from)
      assert expr == to
    end

    for {from, expected_err} <- @elixir_expressions.error do
      assert {:error, actual_err} = Ast.sanitize(from)
      assert actual_err == expected_err
    end
  end

  test "json expression conversions" do
    for {from, to} <- @json_expressions.ok do
      assert {:ok, expr} = Ast.deserialize(%{"ast" => from})
      assert expr == to
      assert {:ok, json} = Ast.serialize(expr)
      assert json == %{"ast" => from}
    end

    for {from, expected_err} <- @json_expressions.error do
      assert {:error, actual_err} = Ast.deserialize(%{"ast" => from})
      assert actual_err == expected_err
    end
  end
end
