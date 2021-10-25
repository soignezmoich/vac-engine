defmodule VacEngineWeb.Editor.DeductionsActionsComponent do
  use Phoenix.Component

  def deductions_actions(assigns) do
    ~H"""
    <div class="w-full disabled divide-black border-pink-600 border-l-4 border-black bg-white filter drop-shadow-lg p-3">
      <div class="font-bold">
        Deduction actions
      </div>
      <hr class="mb-2" />
      <div class="text-sm my-1">
        Name
      </div>
      <input class="form-fld w-full" />
      <div class="h-2" />
    </div>
    """
  end

end
