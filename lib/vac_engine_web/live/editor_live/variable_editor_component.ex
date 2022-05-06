defmodule VacEngineWeb.EditorLive.VariableEditorComponent do
  @moduledoc false

  use VacEngineWeb, :live_component

  import VacEngineWeb.EditorLive.VariableActionGroupComponent
  import VacEngineWeb.InfoComponent

  alias VacEngineWeb.EditorLive.VariableInspectorComponent
  alias VacEngineWeb.EditorLive.VariableListComponent
end
