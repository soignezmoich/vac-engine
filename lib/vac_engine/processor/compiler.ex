defmodule VacEngine.Processor.Compiler do
  alias VacEngine.Processor.Expression
  alias VacEngine.Blueprints.Blueprint
  alias VacEngine.Blueprints.Deduction
  alias VacEngine.Blueprints.Branch

  def eval_expression(expr, bindings \\ %{})

  def eval_expression(%Expression{} = expr, assigns) do
    expr
    |> compile_expression!()
    |> eval_ast(assigns)
  rescue
    e in KeyError ->
      {:error, "variable #{e.key} not found"}
  end

  def eval_expression(expression_ast, bindings) do
    Expression.new(expression_ast)
    |> case do
      {:ok, expr} ->
        eval_expression(expr, bindings)

      err ->
        err
    end
  end

  def eval_ast(compiled_ast, assigns) do
    assigns = Map.new(assigns, fn {k, v} -> {to_string(k), v} end)

    compiled_ast
    |> Code.eval_quoted(assigns: assigns)
    |> case do
      {result, _} -> {:ok, result}
      _ -> {:error, "run error"}
    end
  end

  def compile_expression!(%Expression{} = expr) do
    compile_expression!(expr.ast)
  end

  def compile_expression!({:var, [name]}) when is_binary(name) do
    quote do
      Map.fetch!(var!(assigns), unquote(name))
    end
  end

  def compile_expression!({:var, _}) do
    raise "invalid expression"
  end

  def compile_expression!({fname, args}) do
    fref =
      {:., [],
       [
         quote(do: VacEngine.Processor.Libraries),
         fname
       ]}

    {fref, [], Enum.map(args, &compile_expression!/1)}
  end

  def compile_expression!(const), do: const

  def compile_blueprint(%Blueprint{} = blueprint) do
    fn_asts =
      blueprint.deductions
      |> Enum.map(&compile_deduction/1)
      |> Enum.map(fn f ->
        quote do
          var!(assigns) = unquote(f)
        end
      end)

    ast = {:__block__, [], fn_asts}
    {:ok, ast}
  end

  def compile_deduction(%Deduction{} = deduction) do
    branches_asts =
      deduction.branches
      |> Enum.map(fn br ->
        {conditions_ast, assignements_ast} = compile_branch!(br)

        [q] =
          quote do
            unquote(conditions_ast).() ->
              Map.merge(var!(assigns), unquote(assignements_ast).())
          end

        q
      end)

    branches_asts =
      branches_asts ++
        quote do
          true -> var!(assigns)
        end

    quote do
      cond do
        unquote(branches_asts)
      end
    end
  end

  def compile_branch!(%Branch{} = branch) do
    conditions =
      branch.conditions
      |> Enum.map(fn c ->
        compile_expression!(c.expression)
      end)

    conditions_ast =
      quote do
        fn -> Enum.all?(unquote(conditions)) end
      end

    assignements_ast =
      branch.assignements
      |> Enum.map(fn as ->
        expr = compile_expression!(as.expression)

        {
          as.target,
          expr
        }
      end)

    assignements_ast = {:%{}, [], assignements_ast}

    assignements_ast =
      quote do
        fn -> unquote(assignements_ast) end
      end

    {conditions_ast, assignements_ast}
  end
end
