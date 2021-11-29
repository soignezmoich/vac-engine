defmodule VacEngineWeb.Editor.VariableActionGroupComponent do
  use Phoenix.Component

  import VacEngineWeb.IconComponent

  def variable_action_group(assigns) do
    ~H"""
    <div class="w-full disabled divide-black border-pink-600 border-l-4 border-black bg-white filter drop-shadow-lg p-3">
      <div class="font-bold">
        Variables actions
      </div>
      <hr class="mb-2" />
      <div class="grid grid-cols-1 gap-1.5">
        <button class="btn btn-default">
          <div class="inline-block">
            <.icon name="input" width="1.25rem" />
          </div>
          Add input
        </button>
        <button class="btn btn-default">
          <div class="inline-block">
            <.icon name="hero/variable" width="1.25rem" />
          </div>
          Add intermediate
        </button>
        <button class="btn btn-default">
          <div class="inline-block">
            <.icon name="hero/logout" width="1.25rem" class="inline-block" />
          </div>
          Add output
        </button>
      </div>
    </div>
    """
  end
end
