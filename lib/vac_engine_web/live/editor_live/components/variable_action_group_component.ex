defmodule VacEngineWeb.EditorLive.VariableActionGroupComponent do
  @moduledoc false

  use Phoenix.Component

  import VacEngineWeb.IconComponent

  def variable_action_group(assigns) do
    ~H"""
    <div class="w-full bg-white border shadow p-3 cursor-default">
    <div class="font-bold">
        Variables actions
      </div>
      <hr class="mb-2" />
      <div class="grid grid-cols-1 gap-1.5 text-sm">
        <button class="btn-default flex items-center justify-center"
                phx-click="add_input"
                phx-target="#variable_inspector">
          <div class="mr-1">
            <.icon name="input" width="1.25rem" />
          </div>
          Add input
        </button>
        <button class="btn-default flex items-center justify-center"
                phx-click="add_intermediate"
                phx-target="#variable_inspector">
          <div class="mr-1">
            <.icon name="hero/variable" width="1.25rem" />
          </div>
          Add intermediate
        </button>
        <button class="btn-default flex items-center justify-center"
                phx-click="add_output"
                phx-target="#variable_inspector">
          <div class="mr-1">
            <.icon name="hero/logout" width="1.25rem" class="inline-block" />
          </div>
          Add output
        </button>
      </div>
    </div>
    """
  end
end
