defmodule VacEngineWeb.Editor.VariableInspectorComponent do
  use Phoenix.Component

  def variable_inspector(assigns) do
    ~H"""
    <div class="w-full divide-black border-pink-600 border-r-4 border-black bg-white filter drop-shadow-lg p-3">
      <div class="font-bold">
        Edit variable
      </div>
      <hr class="mb-2" />
      <div class="text-sm my-1">
        Name
      </div>
      <input class="form-fld w-full" />
      <div class="h-2" />
      <div class="text-sm my-1">
        Container
      </div>
      <select class="form-fld w-full">
        <option>root</option>
        <option>container1</option>
        <option>container2</option>
        <option>container1.subcontainer</option>
      </select>
      <div class="h-2" />
      <div class="text-sm my-1">
        Type
      </div>
      <select class="form-fld w-full">
        <option>boolean</option>
        <option>integer</option>
        <option>string</option>
        <option>date</option>
        <option>map</option>
      </select>
      <div class="h-2" />
      <div class="text-sm my-1">
        Allowed values
      </div>
      <div class="inline-block border mr-1 mb-1 pl-2">
        pfizer
        <button class="btn">x</button>
      </div>
      <div class="inline-block border mr-1 mb-1 pl-2">
        moderna
        <button class="btn">x</button>
      </div>
      <div class="inline-block border mr-1 mb-1 pl-2">
        janssen
        <button class="btn">x</button>
      </div>
      <div>
        <div class="inline-block border mr-1 my-1">
          <input class="form-fld w-40" /><button class="btn btn-default">+</button>
        </div>
      </div>
      <div class="h-2" />
      <div class="text-sm my-1">
        Position
      </div>
      <select class="form-fld w-full">
        <option>input</option>
        <option>output</option>
        <option>intermediate</option>
      </select>
      <div class="h-2" />
      <div class="grid grid-cols-2 gap-1.5 mt-1">
        <button class="btn">Cancel</button>
        <button class="btn btn-default">Save</button>
      </div>
    </div>

    """
  end

end
