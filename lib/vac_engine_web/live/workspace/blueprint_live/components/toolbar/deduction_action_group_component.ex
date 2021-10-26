defmodule VacEngineWeb.Editor.DeductionActionGroupComponent do
  use Phoenix.Component

  alias VacEngineWeb.Icons

  def deduction_action_group(assigns) do
    ~H"""
    <div class="w-full border-pink-600 border-r-4 border-black bg-white filter drop-shadow-lg p-3">
      <div class="font-bold mb-2 border-b border-black">
        Deduction actions
      </div>
      <div class="grid grid-cols-4 my-1 gap-1.5 w-full">
        <div class="btn btn-default flex justify-center items-center">
          <Icons.add />
        </div>
        <div class="btn btn-default flex justify-center items-center">
          <Icons.up />
        </div>
        <div class="btn btn-default flex justify-center items-center">
          <Icons.down />
        </div>
        <div class="btn btn-default flex justify-center items-center">
          <Icons.delete />
        </div>
      </div>
      <div class="font-bold mb-2 border-b border-black">
        Branch actions
      </div>
      <div class="grid grid-cols-4 my-1 gap-1.5 w-full">
        <div class="btn btn-default flex justify-center items-center">
          <Icons.add />
        </div>
        <div class="btn btn-default flex justify-center items-center">
          <Icons.up />
        </div>
        <div class="btn btn-default flex justify-center items-center">
          <Icons.down />
        </div>
        <div class="btn btn-default flex justify-center items-center">
          <Icons.delete />
        </div>
      </div>
      <div class="font-bold mb-2 border-b border-black">
        Column actions
      </div>
      <div class="grid grid-cols-4 my-1 gap-1.5 w-full">
        <div class="btn btn-default flex justify-center items-center">
          <Icons.add />
        </div>
        <div class="btn btn-default flex justify-center items-center">
          <Icons.left />
        </div>
        <div class="btn btn-default flex justify-center items-center">
          <Icons.right />
        </div>
        <div class="btn btn-default flex justify-center items-center">
          <Icons.delete />
        </div>
      </div>
    </div>
    """
  end

end
