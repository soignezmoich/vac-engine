defmodule VacEngineWeb.Editor.ExpressionEditorComponent do
  use Phoenix.Component

  import VacEngineWeb.IconComponent

  def expression_editor(assigns) do
    ~H"""
    <div class="w-full bg-white filter drop-shadow-lg" >
    <div class="h-2" />

      <div class="w-full px-2 py-1">
        <div class="font-bold mb-2 border-b border-black">
          Cell value
        </div>
        <.constant_picker />
        <div class="h-2"/>
        <.variable_picker />
        <div class="h-2"/>
        <.function_picker />
      </div>
    </div>
    """
  end

  defp constant_picker(assigns) do
    ~H"""
    <div class="p-1 border border-black bg-gray-100 opacity-50 cursor-pointer">
      <div class="text-sm">
        Constant
      </div>
      <select class="form-fld w-full text-sm cursor-pointer">
        <option>constant-boolean</option>
        <option>constant-integer</option>
        <option>constant-number</option>
        <option>constant-date</option>
        <option>constant-string</option>
        <option>constant-enum</option>
      </select>
      <!--
      <div class="h-1"/>
      <input class="form-fld w-full text-sm" />
      -->
    </div>
    """
  end

  defp variable_picker(assigns) do
    ~H"""
    <div class="border-2 border-blue-600 shadow shadow-black bg-blue-50 p-1 cursor-pointer">
      <div class="text-sm">
        Variable
      </div>
      <select class="form-fld w-full text-sm cursor-pointer">
        <optgroup label="integer">
          <option>@age</option>
        </optgroup>
        <optgroup label="string">
          <option>@first_name</option>
          <option>@last_name</option>
        </optgroup>
      </select>
    </div>
    """
  end

  defp function_picker(assigns) do
    ~H"""
    <div class="pt-1 pb-2 px-2 border border-black bg-gray-100 opacity-50 cursor-pointer">
      <div class="text-sm">
        Function
      </div>
      <select class="form-fld w-full text-sm cursor-pointer">
        <option>gt</option>
        <option>lt</option>
        <option>eq</option>
        <option>neq</option>
      </select>
      <div class="w-full px-2 py-1">
        <div class="font-bold mb-2 border-b border-black">
          <div class="inline-block -mb-1">
            <.icon name="hero/arrow-right" width="1.25rem" />
          </div>
          Argument #1
        </div>
        <.constant_picker />
        <div class="h-2"/>
        <.variable_picker />
      </div>
      <div class="w-full px-2 py-1">
        <div class="font-bold mb-2 border-b border-black">
          <div class="inline-block -mb-1">
            <.icon name="hero/arrow-right" width="1.25rem" />
          </div>
          Argument #2
        </div>
        <.constant_picker />
        <div class="h-2"/>
        <.variable_picker />
      </div>
    </div>
    """
  end
end
