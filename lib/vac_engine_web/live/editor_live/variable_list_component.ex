defmodule VacEngineWeb.EditorLive.VariableListComponent do
  use VacEngineWeb, :live_component

  import VacEngine.PipeHelpers
  alias VacEngineWeb.EditorLive.VariableSubListComponent

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
        socket
      ) do
    socket
    |> assign(build_renderable(blueprint))
    |> assign(assigns)
    |> ok()
  end

  def build_renderable(blueprint) do
    %{
      input_variables: blueprint.input_variables,
      output_variables: blueprint.output_variables,
      intermediate_variables: blueprint.intermediate_variables
    }
  end
end
