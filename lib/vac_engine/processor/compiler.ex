defmodule VacEngine.Processor.Compiler do
  alias VacEngine.Processor.State
  alias VacEngine.Processor.Expression
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Deduction
  alias VacEngine.Processor.Branch
  alias VacEngine.Processor.Ast

  def eval_expression(expr, input \\ %{})

  def eval_expression(%Expression{} = expr, bindings) do
    state = %State{heap: bindings}

    expr
    |> compile_expression!()
    |> eval_ast(state)
  catch
    {_code, msg} ->
      {:error, msg}
  end

  def eval_expression(expression_ast, bindings) do
    Ast.sanitize(expression_ast)
    |> case do
      {:ok, ast} ->
        eval_expression(%Expression{ast: ast}, bindings)

      err ->
        err
    end
  end

  def eval_ast(compiled_ast, %State{} = state) do
    compiled_ast
    |> Code.eval_quoted(state: state)
    |> case do
      {:error, _} ->
        {:error, "run error"}

      {result, _} ->
        {:ok, result}
    end
  catch
    {_code, msg} ->
      {:error, msg}
  end

  def compile_expression!(nil), do: nil

  def compile_expression!(%Expression{} = expr) do
    compile_ast!(expr.ast)
  end

  def compile_ast!({:var, _m, [path]}) do
    quote do
      VacEngine.Processor.State.get_var(var!(state), unquote(path))
    end
  end

  def compile_ast!({:var, _m, _arg}) do
    raise "invalid call of var/1"
  end

  def compile_ast!({fname, _m, args}) do
    fref =
      {:., [],
       [
         quote(do: VacEngine.Processor.Library.Functions),
         fname
       ]}

    {fref, [], Enum.map(args, &compile_ast!/1)}
  end

  def compile_ast!(const), do: const

  def compile_blueprint(%Blueprint{deductions: []}) do
    {:ok, quote(do: var!(state))}
  end

  def compile_blueprint(%Blueprint{} = blueprint) do
    fn_asts =
      blueprint.deductions
      |> Enum.map(&compile_deduction/1)
      |> Enum.map(fn f ->
        quote do
          var!(state) = unquote(f)
        end
      end)

    ast = {:__block__, [], fn_asts}
    {:ok, ast}
  catch
    {_code, msg} ->
      {:error, msg}
  end

  def compile_deduction(%Deduction{} = deduction) do
    branches_asts =
      deduction.branches
      |> Enum.map(fn br ->
        {conditions_ast, assignments_ast} = compile_branch!(br)

        [q] =
          quote do
            unquote(conditions_ast) ->
              VacEngine.Processor.State.merge_vars(
                var!(state),
                unquote(assignments_ast).()
              )
          end

        q
      end)

    branches_asts =
      branches_asts ++
        quote do
          true -> var!(state)
        end

    quote do
      cond do
        unquote(branches_asts)
      end
    end
  end

  def compile_branch!(%Branch{} = branch) do
    conditions_ast =
      branch.conditions
      |> case do
        [] ->
          quote(do: true)

        nil ->
          quote(do: true)

        conds ->
          ast =
            conds
            |> Enum.map(fn c ->
              compile_expression!(c.expression)
            end)

          quote do
            Enum.all?(unquote(ast))
          end
      end

    assignments_ast =
      branch.assignments
      |> Enum.map(fn as ->
        expr = compile_expression!(as.expression)

        {
          as.target,
          expr
        }
      end)

    assignments_ast = {:%{}, [], assignments_ast}

    assignments_ast =
      quote do
        fn -> unquote(assignments_ast) end
      end

    {conditions_ast, assignments_ast}
  end
end
