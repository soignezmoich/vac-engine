defmodule VacEngine.Processor.AstTest do
  use ExUnit.Case

  alias VacEngine.Processor.Ast

  @elixir_ast %{
    ok: [
      {~D[2020-06-23], {:date, [], [2020, 6, 23]}},
      {~N[2020-06-23 14:02:12], {:datetime, [], [2020, 6, 23, 14, 2, 12]}},
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
  @json_ast %{
    ok: [
      {%{"l" => "datetime", "r" => [2020, 4, 23, 16, 23, 14], "m" => %{}},
       {:datetime, [], [2020, 4, 23, 16, 23, 14]}},
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

  test "elixir ast conversions" do
    for {from, to} <- @elixir_ast.ok do
      assert {:ok, expr} = Ast.sanitize(from)
      assert expr == to
    end

    for {from, expected_err} <- @elixir_ast.error do
      assert {:error, actual_err} = Ast.sanitize(from)
      assert actual_err == expected_err
    end
  end

  test "json ast conversions" do
    for {from, to} <- @json_ast.ok do
      assert {:ok, expr} = Ast.deserialize(%{"ast" => from})
      assert expr == to
      assert {:ok, json} = Ast.serialize(expr)
      assert json == %{"ast" => from}
    end

    for {from, expected_err} <- @json_ast.error do
      assert {:error, actual_err} = Ast.deserialize(%{"ast" => from})
      assert actual_err == expected_err
    end
  end

  @sig_ast [
    {~D[2010-01-02], {:date, [signature: {[], :date}], [2010, 1, 2]}},
    {quote(do: gt(4, 9)),
     {:gt, [signature: {[:integer, :integer], :boolean}], [4, 9]}},
    {quote(do: gt(4, @a)),
     {:gt, [signature: {[:integer, :number], :boolean}],
      [4, {:var, [signature: {[:name], :number}], [0]}]}}
  ]

  test "insert signature" do
    for {from, to} <- @sig_ast do
      assert {:ok, ast} = Ast.sanitize(from)
      assert {:ok, {ast, _}} = Ast.extract_bindings(ast)
      assert {:ok, ast} = Ast.insert_signatures(ast, [:number])
      assert ast == to
    end
  end
end
