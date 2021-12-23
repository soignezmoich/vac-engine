defmodule VacEngine.Processor.Compiler do
  @moduledoc """
  Compile AST

  Not to be used directly, use the `VacEngine.Processor` interface.
  """
  alias VacEngine.Processor.State
  alias VacEngine.Processor.Expression
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Deduction
  alias VacEngine.Processor.Branch
  alias VacEngine.Processor.Ast

  @doc """
  Eval an expression (will use eval_ast/2)
  """
  def eval_expression(expr, input \\ %{})

  def eval_expression(%Expression{} = expr, bindings) do
    state = %State{heap: bindings}

    expr
    |> compile_expression!()
    |> eval_ast(state)
  catch
    {code, msg} ->
      {:error, "#{code}: #{msg}"}
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

  @doc """
  Eval AST
  """
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
    {code, msg} ->
      {:error, "#{code}: #{msg}"}
  end

  @doc """
  Compile an expression and return AST
  """
  def compile_expression!(nil), do: nil

  def compile_expression!(%Expression{} = expr) do
    compile_ast!(expr.ast)
  end

  @doc false
  def compile_ast!({:var, _m, [path]}) do
    quote do
      VacEngine.Processor.State.get_var(var!(state), unquote(path))
    end
  end

  def compile_ast!({:var, _m, _args}) do
    throw({:invalid_var, "invalid call of var/1"})
  end

  def compile_ast!({:now, m, args}) do
    compile_ast!({:now_, m, args})
    |> prepend_state_arg()
  end

  def compile_ast!({:age, m, args}) do
    compile_ast!({:age_, m, args})
    |> prepend_state_arg()
  end

  def compile_ast!({:not, m, args}), do: compile_ast!({:not_, m, args})
  def compile_ast!({:and, m, args}), do: compile_ast!({:and_, m, args})
  def compile_ast!({:or, m, args}), do: compile_ast!({:or_, m, args})
  def compile_ast!({:is_nil, m, args}), do: compile_ast!({:is_nil_, m, args})

  def compile_ast!({:date, _m, [year, month, day]}) do
    quote do
      Date.from_erl!({unquote(year), unquote(month), unquote(day)})
    end
  end

  def compile_ast!({:datetime, _m, [year, month, day, hour, minute, second]}) do
    quote do
      NaiveDateTime.from_erl!(
        {{unquote(year), unquote(month), unquote(day)},
         {unquote(hour), unquote(minute), unquote(second)}}
      )
    end
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

  defp prepend_state_arg({fref, m, args}) do
    state = quote(do: var!(state))
    {fref, m, [state | args]}
  end

  defp compile_blueprint_ast(ast, blueprint) do
    id = blueprint.id

    quote do
      defmodule unquote(:"Elixir.VacEngine.Processor.BlueprintCode.I#{id}") do
        require Logger

        def run(state) do
          var!(state) = state
          unquote(ast)
          var!(state)
        end
      end
    end
    |> Code.compile_quoted()
    |> then(fn [{mod, _}] -> mod end)
  end

  @doc """
  Compile a blueprint and return AST
  """
  def compile_blueprint(%Blueprint{deductions: []} = br) do
    {:ok, nil |> compile_blueprint_ast(br)}
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

    now = Timex.format!(Timex.now(), "{ISOdate} {ISOtime}Z")
    br_info = "Blueprint: ##{blueprint.id}. Name: #{blueprint.name}. " <>
              "Compiled: #{now}. App version: #{VacEngine.version}."

    fn_asts = [
      quote do
        Logger.info(unquote(br_info))
      end
      | fn_asts
    ]

    ast = {:__block__, [], fn_asts}
    {:ok, ast |> compile_blueprint_ast(blueprint)}
  catch
    {code, msg} ->
      {:error, "#{code}: #{msg}"}
  end

  @doc false
  def compile_deduction(%Deduction{} = ded) do
    branches_asts =
      ded.branches
      |> Enum.map(fn br ->
        {conditions_ast, assignments_ast} = compile_branch!(br)

        ded_info = ded.description || ded.position
        br_info = br.description || br.position

        ass_info =
          br.assignments
          |> Enum.filter(fn a -> a.description end)
          |> Enum.map(fn a ->
            "-- #{a.target |> Enum.join(".")} = #{a.description}"
          end)

        info = "#{ded_info} -> #{br_info}"

        [q] =
          quote do
            unquote(conditions_ast) ->
              Logger.info(unquote(info))

              unquote(ass_info)
              |> Enum.each(&Logger.info/1)

              VacEngine.Processor.State.merge_vars(
                var!(state),
                unquote(assignments_ast).()
              )
          end

        q
      end)

    info = "#{ded.description || ded.position}: default"

    branches_asts =
      branches_asts ++
        quote do
          true ->
            Logger.info(unquote(info))
            var!(state)
        end

    ast =
      quote do
        cond do
          unquote(branches_asts)
        end
      end

    ast
  end

  @doc false
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
