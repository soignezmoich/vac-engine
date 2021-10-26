defmodule VacEngineWeb.Editor.VariableEditorComponent do
  use VacEngineWeb, :live_component

  import Elixir.Integer
  import VacEngineWeb.Editor.FormActionGroupComponent
  import VacEngineWeb.Editor.VariableActionGroupComponent
  import VacEngineWeb.Editor.VariableComponent
  import VacEngineWeb.Editor.VariableInspectorComponent

  alias VacEngineWeb.Editor.VariableRenderable

  def update(assigns, socket) do
    renderable_variables = VariableRenderable.build(assigns.variables, nil)

    {:ok,
     assign(socket,
       input_variables: renderable_variables.input,
       output_variables: renderable_variables.output,
       intermediate_variables: renderable_variables.intermediate
     )}
  end
end
