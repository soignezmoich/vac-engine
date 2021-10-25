defmodule VacEngineWeb.Editor.FormActionsComponent do
  use Phoenix.Component

  def form_actions(assigns) do
    ~H"""
    <div class="w-full disabled divide-black border-pink-600 border-l-4 border-black bg-white filter drop-shadow-lg p-3">
      <div class="font-bold">
        Form actions
      </div>
      <hr class="mb-2" />
      <div class="grid grid-cols-2 gap-1.5">
        <button class="btn btn-default">Open</button>
        <button class="btn btn-default">Save</button>
        <button class="btn btn-default">Publish</button>
        <button class="btn btn-default">Save as</button>
      </div>
    </div>
    """
  end

end
