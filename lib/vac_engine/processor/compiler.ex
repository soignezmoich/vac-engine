defmodule VacEngine.Processor.Compiler do
  alias VacEngine.Processor.State
  alias VacEngine.Processor.Expression
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Deduction
  alias VacEngine.Processor.Branch

  def eval_expression(expr, input \\ %{})

  def eval_expression(%Expression{} = expr, bindings) do
    state = %State{stack: bindings}

    expr
    |> compile_expression!()
    |> eval_ast(state)
  catch
    {_code, msg} ->
      {:error, msg}
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

  def eval_ast(compiled_ast, %State{} = state) do
    compiled_ast
    # |> debug_ast()
    |> Code.eval_quoted(state: state)
    |> case do
      {state, _} ->
        {:ok, state}

      _ ->
        {:error, "run error"}
    end
  catch
    {_code, msg} ->
      {:error, msg}
  end

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
         quote(do: VacEngine.Processor.Libraries),
         fname
       ]}

    {fref, [], Enum.map(args, &compile_ast!/1)}
  end

  def compile_ast!(const), do: const

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
  end

  def compile_deduction(%Deduction{} = deduction) do
    branches_asts =
      deduction.branches
      |> Enum.map(fn br ->
        {conditions_ast, assignements_ast} = compile_branch!(br)

        [q] =
          quote do
            unquote(conditions_ast) ->
              VacEngine.Processor.State.merge_vars(
                var!(state),
                unquote(assignements_ast).()
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

  defp debug_ast(ast) do
    Macro.to_string(ast)
    |> Code.format_string!()
    |> IO.puts()

    ast
  end
end
