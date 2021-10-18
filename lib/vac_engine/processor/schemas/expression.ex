defmodule VacEngine.Processor.Expression do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.AstType
  alias VacEngine.Processor.Binding
  alias VacEngine.Processor.Ast
  alias VacEngine.Processor.Meta
  import VacEngine.EctoHelpers
  import VacEngine.TupleHelpers

  schema "expressions" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:blueprint, Blueprint)

    has_many(:bindings, Binding, on_replace: :delete)

    field(:ast, AstType)
  end

  def changeset(data, attrs, ctx, opts \\ [])

  def changeset(data, attrs, ctx, opts) do
    nobindings = Keyword.get(opts, :nobindings, false)

    attrs
    |> get_in_attrs(:ast)
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

  defp extract_binding_names(ast) do
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

  defp forbid_bindings({:ok, {ast, bindings}}, true) do
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
end
