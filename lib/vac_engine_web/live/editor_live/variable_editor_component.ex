defmodule VacEngineWeb.EditorLive.VariableEditorComponent do
  use VacEngineWeb, :live_component

  import VacEngineWeb.EditorLive.VariableActionGroupComponent
  alias VacEngineWeb.EditorLive.VariableInspectorComponent
  alias VacEngineWeb.EditorLive.VariableListComponent
  alias VacEngine.Processor.Variable
  import VacEngine.PipeHelpers

  @impl true
  def mount(socket) do
    {:ok, assign(socket, selected_variable: nil)}
  end

  @impl true
  def update(%{action: {:select_variable, var}}, socket) do
    {:ok, assign(socket, selected_variable: var)}
  end

  @impl true
  def update(
        %{blueprint: blueprint} = assigns,
        %{assigns: %{selected_variable: %Variable{id: id}}} = socket
      ) do
    socket
    |> assign(selected_variable: Map.get(blueprint.variable_id_index, id))
    |> assign(assigns)
    |> ok()
  end

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end
