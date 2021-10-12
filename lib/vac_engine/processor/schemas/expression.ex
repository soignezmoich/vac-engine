defmodule VacEngine.Processor.Expression do
  use Ecto.Schema
  import Ecto.Changeset

  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.AstType
  alias VacEngine.Processor.Binding
  alias VacEngine.Processor.Ast
  import VacEngine.EctoHelpers
  import VacEngine.TupleHelpers

  schema "expressions" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:blueprint, Blueprint)

    has_many(:bindings, Binding, on_replace: :delete)

    field(:ast, AstType)
  end

  def changeset(data, attrs, ctx, _opts \\ []) do
    attrs =
      attrs
      |> get_in_attrs(:ast)
      |> extract_bindings()
      |> case do
        {:ok, {ast, bindings}} ->
          bindings =
            bindings
            |> Enum.with_index()
            |> Enum.map(fn {path, idx} ->
              %{position: idx, path: path}
            end)

          bindings = get_in_attrs(attrs, :bindings, []) ++ bindings

          attrs
          |> put_in_attrs(:ast, ast)
          |> put_in_attrs(:bindings, bindings)
          |> ok()

        {:error, _err} = err ->
          err
      end

    case attrs do
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
        |> cast(attrs, [])
        |> add_error(:ast, err)
    end
  end

  defp extract_bindings(ast) do
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
end
