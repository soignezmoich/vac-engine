defmodule VacEngineWeb.Workspace.BlueprintLive.CodeEditorComponent do
  use VacEngineWeb, :component

  def code_editor(assigns) do
    ~H"""
    <textarea class="w-full flex-grow text-xs">
      <%= @source %>
    </textarea>
    """
  end
end
