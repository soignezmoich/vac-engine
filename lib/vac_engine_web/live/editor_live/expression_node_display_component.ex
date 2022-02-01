defmodule VacEngineWeb.EditorLive.ExpressionNodeDisplayComponent do
  use VacEngineWeb, :live_component

  import VacEngine.PipeHelpers
  alias VacEngine.Processor.Ast

  @impl true
  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> parse_ast()
    |> ok()
  end

  def parse_ast(%{assigns: %{ast: nil}} = socket) do
    assign(socket, type: :constant, value: nil)
  end

  def parse_ast(%{assigns: %{ast: ast}} = socket) do
    node_type = Ast.node_type(ast)

    node_type
    |> case do
      :constant ->
        assign(socket, type: :constant, value: Ast.describe(ast))

      :variable ->
        assign(socket, type: :variable, name: Ast.variable_name(ast))

      :function ->
        fname = Ast.function_name(ast)

        args =
          ast
          |> Ast.function_arguments()
          |> Enum.with_index()
          |> Enum.map(fn {a, i} ->
            %{ast: a, index: i}
          end)

        assign(socket,
          type: :function,
          name: fname,
          arguments: args
        )
    end
  end
end
