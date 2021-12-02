defmodule VacEngineWeb.Editor.DeductionActionGroupComponent do
  use Phoenix.Component

  import VacEngineWeb.IconComponent

  def deduction_action_group(assigns) do
    ~H"""
    <div class="w-full border-pink-600 border-r-4 border-black bg-white filter drop-shadow-lg p-3">
      <div class="font-bold mb-2 border-b border-black">
        Deduction actions
      </div>
      <div class="grid grid-cols-4 my-1 gap-1.5 w-full">
        <div class="btn btn-default flex justify-center items-center">
          <.icon name="hero/plus" width="1.25rem" />
        </div>
        <div class="btn btn-default flex justify-center items-center">
          <.icon name="hero/arrow-up" width="1.25rem" />
        </div>
        <div class="btn btn-default flex justify-center items-center">
          <.icon name="hero/arrow-down" width="1.25rem" />
        </div>
        <div class="btn btn-default flex justify-center items-center">
          <.icon name="hero/trash" width="1.25rem" />
        </div>
      </div>
      <div class="font-bold mb-2 border-b border-black">
        Branch actions
      </div>
      <div class="grid grid-cols-4 my-1 gap-1.5 w-full">
        <div class="btn btn-default flex justify-center items-center">
          <.icon name="hero/plus" width="1.25rem" />
        </div>
        <div class="btn btn-default flex justify-center items-center">
          <.icon name="hero/arrow-up" width="1.25rem" />
        </div>
        <div class="btn btn-default flex justify-center items-center">
          <.icon name="hero/arrow-down" width="1.25rem" />
        </div>
        <div class="btn btn-default flex justify-center items-center">
          <.icon name="hero/trash" width="1.25rem" />
        </div>
      </div>
      <div class="font-bold mb-2 border-b border-black">
        Column actions
      </div>
      <div class="grid grid-cols-4 my-1 gap-1.5 w-full">
        <div class="btn btn-default flex justify-center items-center">
          <.icon name="hero/plus" width="1.25rem" />
        </div>
        <div class="btn btn-default flex justify-center items-center">
          <.icon name="hero/arrow-left" width="1.25rem" />
        </div>
        <div class="btn btn-default flex justify-center items-center">
          <.icon name="hero/arrow-right" width="1.25rem" />
        </div>
        <div class="btn btn-default flex justify-center items-center">
          <.icon name="hero/trash" width="1.25rem" />
        </div>
      </div>
    </div>
    """
  end
end
