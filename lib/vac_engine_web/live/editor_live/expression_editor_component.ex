defmodule VacEngineWeb.EditorLive.ExpressionEditorComponent do
  use VacEngineWeb, :live_component

  import VacEngine.PipeHelpers
  alias VacEngine.Processor
  alias VacEngineWeb.EditorLive.ExpressionNodeEditorComponent

  @impl true
  def mount(socket) do
    socket
    |> assign(
      cell_id: nil,
      expression: nil,
      type: :constant,
      changeset: nil,
      return_type: nil,
      transient_ast: nil
    )
    |> ok()
  end

  @impl true
  def update(%{action: {:update_ast, ast}}, socket) do
    {:ok, assign(socket, transient_ast: ast)}
  end

  @impl true
  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> parse_expression()
    |> ok()
  end

  @impl true
  def handle_event("cancel", _, socket) do
    {:noreply, socket |> bump_form_id()}
  end

  @impl true
  def handle_event(
        "delete",
        _,
        %{
          assigns: %{
            column: column,
            branch: branch
          }
        } = socket
      ) do
    {:ok, _} = Processor.delete_cell(branch, column)

    send(self(), :reload_blueprint)

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "save",
        _,
        %{
          assigns: %{
            transient_ast: ast,
            blueprint: blueprint,
            column: column,
            branch: branch
          }
        } = socket
      ) do
    {:ok, _} = Processor.update_cell(ast, blueprint, branch, column)

    send(self(), :reload_blueprint)

    {:noreply, socket}
  end

  defp parse_expression(
         %{
           assigns: %{
             expression: expression,
             branch: branch,
             column: column,
             blueprint: blueprint
           }
         } = socket
       ) do
    cell_id = "cell.#{column.id}.#{branch.id}"
    var = blueprint.variable_path_index |> Map.get(column.variable)

    return_type =
      case column.type do
        :condition -> :boolean
        :assignment -> var.type
      end

    ast =
      case expression do
        %{ast: ast} -> ast
        _ -> nil
      end

    socket
    |> assign(
      return_type: return_type,
      cell_id: cell_id,
      ast: ast,
      column: column,
      transient_ast: ast
    )
    |> bump_form_id()
  end

  defp bump_form_id(%{assigns: %{cell_id: cell_id}} = socket) do
    assign(socket, form_id: "#{cell_id}.#{:os.system_time()}")
  end
end
