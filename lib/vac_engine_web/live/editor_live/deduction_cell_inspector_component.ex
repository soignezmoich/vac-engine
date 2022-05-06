defmodule VacEngineWeb.EditorLive.DeductionCellInspectorComponent do
  @moduledoc false

  use VacEngineWeb, :live_component

  import VacEngine.PipeHelpers

  alias VacEngine.Processor
  alias VacEngine.Processor.Expression
  alias VacEngineWeb.EditorLive.ExpressionNodeEditorComponent
  alias VacEngineWeb.EditorLive.DeductionCellInspectorComponent

  @impl true
  def mount(socket) do
    socket
    |> assign(
      cell_id: nil,
      cell: nil,
      type: :constant,
      changeset: nil,
      return_type: nil,
      transient_ast: nil,
      transient_ast_opts: nil,
      error: nil,
      description: nil,
      exrepssion: nil
    )
    |> ok()
  end

  @impl true
  def update(%{action: {:update_ast, ast, opts}}, socket) do
    socket
    |> assign(transient_ast: ast, transient_ast_opts: opts, error: nil)
    |> ok()
  end

  @impl true
  def update(%{action: :save}, socket) do
    {:noreply, socket} = handle_event("save", nil, socket)
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    socket
    |> assign(error: nil)
    |> assign(assigns)
    |> extract_cell()
    |> parse_expression()
    |> ok()
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket
    |> assign(error: nil)
    |> extract_cell()
    |> bump_form_id()
    |> noreply()
  end

  @impl true
  def handle_event(
        "update",
        %{"cell" => %{"description" => description}},
        socket
      ) do
    socket
    |> assign(description: description)
    |> noreply()
  end

  @impl true
  def handle_event(
        "save",
        _,
        %{
          assigns: %{
            column: column,
            branch: branch,
            transient_ast_opts: %{delete: true}
          }
        } = socket
      ) do
    {:ok, _} = Processor.delete_cell(branch, column)

    send(self(), :reload_blueprint)

    socket
    |> assign(error: nil)
    |> noreply()
  end

  @impl true
  def handle_event(
        "save",
        _,
        %{
          assigns: %{
            transient_ast: ast,
            transient_ast_opts: %{set_nil: set_nil},
            blueprint: blueprint,
            column: column,
            branch: branch,
            description: description
          }
        } = socket
      ) do
    cond do
      is_nil(ast) and not set_nil ->
        :error

      true ->
        Processor.update_cell(ast, blueprint, branch, column, %{
          description: description
        })
    end
    |> case do
      {:ok, _res} ->
        send(self(), :reload_blueprint)
        {:noreply, socket}

      _ ->
        socket
        |> assign(error: "Cannot save changes")
        |> noreply()
    end
  end

  defp extract_cell(
         %{
           assigns: %{
             cell: cell
           }
         } = socket
       ) do
    {expression, description} =
      case cell do
        %{expression: e, description: d} -> {e, d}
        _ -> {%Expression{}, nil}
      end

    socket
    |> assign(
      description: description,
      expression: expression
    )
  end

  defp parse_expression(
         %{
           assigns: %{
             cell: cell,
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
      transient_ast: ast,
      transient_ast_opts: %{
        delete: is_nil(cell),
        set_nil: !is_nil(cell) && is_nil(ast)
      }
    )
    |> bump_form_id()
  end

  defp bump_form_id(%{assigns: %{cell_id: cell_id}} = socket) do
    socket
    |> assign(form_id: "#{cell_id}.#{:os.system_time()}")
  end
end
