defmodule VacEngineWeb.Editor.VariableActionGroupComponent do
  use Phoenix.Component

  alias VacEngineWeb.Icons

  def variables_action_group(assigns) do
    ~H"""
    <div class="w-full disabled divide-black border-pink-600 border-l-4 border-black bg-white filter drop-shadow-lg p-3">
      <div class="font-bold">
        Variables actions
      </div>
      <hr class="mb-2" />
      <div class="grid grid-cols-1 gap-1.5">
        <button class="btn btn-default">
          <Icons.input />
          Add input
        </button>
        <button class="btn btn-default">
          <Icons.variable />
          Add intermediate
        </button>
        <button class="btn btn-default">
          <Icons.output />
          Add output
        </button>
      </div>
    </div>
    """
  end

end
