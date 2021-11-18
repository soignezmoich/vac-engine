defmodule VacEngine.Processor.Expression do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.AstType
  alias VacEngine.Processor.Binding
  alias VacEngine.Processor.Ast
  alias VacEngine.Processor.Column
  alias VacEngine.Processor.Condition
  alias VacEngine.Processor.Assignment
  alias VacEngine.Processor.Expression
  alias VacEngine.Processor.Variable
  alias VacEngine.Processor.Meta
  import VacEngine.EctoHelpers
  import VacEngine.PipeHelpers

  schema "expressions" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:blueprint, Blueprint)
    belongs_to(:variable, Variable)
    belongs_to(:column, Column)
    belongs_to(:condition, Condition)
    belongs_to(:assignment, Assignment)

    has_many(:bindings, Binding, on_replace: :delete_if_exists)

    field(:ast, AstType)
  end

  @doc """
  Describe an expression (to_string())
  """
  def describe(expression) do
    expression.ast
    |> Ast.describe()
  end

  @doc false
  def changeset(data, attrs, ctx, opts \\ [])

  @doc false
  def changeset(data, attrs, ctx, opts) do
    nobindings = Keyword.get(opts, :nobindings, false)

    attrs
    |> get_in_attrs(:ast)
    |> deserialize_ast()
    |> extract_binding_names()
    |> forbid_bindings(nobindings)
    |> extract_binding_types(ctx)
    |> insert_signatures()
    |> insert_binding_attrs(attrs)
    |> case do
      {:ok, attrs} ->
        data
        |> cast(attrs, [:ast])
        |> change(
          blueprint_id: ctx.blueprint_id,
          workspace_id: ctx.workspace_id
        )
        |> cast_assoc(:bindings, with: {Binding, :changeset, [ctx]})
        |> validate_required([])

      {:error, err} ->
        data
        |> cast(%{}, [])
        |> add_error(:ast, err)
    end
  end

  @doc false
  def insert_bindings(expression, %{variable_id_index: _index} = ctx) do
    bindings =
      get_in(expression, [
        Access.key(:bindings),
        Access.filter(fn b -> b.position >= 0 end)
      ])
      |> Enum.map(fn bind ->
        Binding.to_path(bind, ctx)
      end)

    expression.ast
    |> Ast.insert_bindings(bindings)
    |> case do
      {:ok, ast} ->
        put_in(expression, [Access.key(:ast)], ast)

      {:error, _} ->
        put_in(expression, [Access.key(:ast)], nil)
    end
  end

  defp deserialize_ast(%{"ast" => _content} = ast) do
    Ast.deserialize(ast)
  end

  defp deserialize_ast(ast), do: {:ok, ast}

  defp extract_binding_names({:error, msg}), do: {:error, msg}

  defp extract_binding_names({:ok, ast}) do
    ast
    |> Ast.sanitize()
    |> case do
      {:ok, ast} ->
        ast
        |> Ast.extract_bindings()

      err ->
        err
    end
  end

  defp forbid_bindings(res, false), do: res
  defp forbid_bindings({:error, err}, true), do: {:error, err}
  defp forbid_bindings({:ok, {_ast, []}} = res, true), do: res

  defp forbid_bindings({:ok, {_ast, _bindings}}, true) do
    {:error, "binding are forbidden in this context"}
  end

  defp extract_binding_types({:ok, {ast, bindings}}, ctx) do
    bindings
    |> Enum.reduce({:ok, []}, fn
      _, {:error, msg} ->
        {:error, msg}

      path, {:ok, bindings} ->
        vpath = path |> Enum.reject(&is_integer/1)

        case Map.get(ctx.variable_path_index, vpath) do
          nil ->
            {:error, "variable #{path} not found"}

          var ->
            type =
              if path |> List.last() |> is_integer() do
                var.type |> Meta.itemize_type()
              else
                var.type
              end

            {:ok, bindings ++ [{path, type}]}
        end
    end)
    |> case do
      {:ok, bindings} ->
        {:ok, {ast, bindings}}

      {:error, err} ->
        {:error, err}
    end
  end

  defp extract_binding_types(err, _ctx), do: err

  defp insert_signatures({:ok, {ast, bindings}}) do
    types =
      bindings
      |> Enum.map(fn {_path, type} -> type end)

    Ast.insert_signatures(ast, types)
    |> case do
      {:ok, ast} ->
        {:ok, {ast, bindings}}

      {:error, err} ->
        {:error, err}
    end
  end

  defp insert_signatures(err), do: err

  defp insert_binding_attrs({:ok, {ast, bindings}}, attrs) do
    bindings =
      bindings
      |> Enum.with_index()
      |> Enum.map(fn {{path, _type}, idx} ->
        %{position: idx, path: path}
      end)

    bindings = get_in_attrs(attrs, :bindings, []) ++ bindings

    attrs
    |> put_in_attrs(:ast, ast)
    |> put_in_attrs(:bindings, bindings)
    |> ok()
  end

  defp insert_binding_attrs(err, _), do: err

  @doc """
  Convert to map for serialization
  """
  def to_map(nil), do: nil

  def to_map(%Expression{} = e) do
    Ast.serialize(e.ast)
    |> case do
      {:ok, ast} -> ast
      _ -> nil
    end
  end
end
