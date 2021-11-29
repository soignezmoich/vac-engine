defmodule VacEngineWeb.Editor.VariableInspectorComponent do
  use Phoenix.Component

  alias VacEngine.Processor.Variable

  def variable_inspector(%{variable: nil} = assigns) do
    ~H"""
    <div>
      No variable selected
    </div>
    """
  end

  def variable_inspector(assigns) do
    ~H"""
    <div class="w-full divide-black border-black bg-white filter drop-shadow-lg p-3">
      <div class="font-bold">
        Edit variable
      </div>
      <hr class="mb-2" />
      <div class="text-sm my-1">
        Variable name
      </div>
      <input class="form-fld w-full" value={@variable.name} />
      <div class="h-2" />
      <div class="text-sm my-1">
        Container
      </div>
      <select class="form-fld w-full">
        <option><%= @variable.path |> Enum.drop(-1) |> Enum.join(".") %></option>
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
        <option selected={@variable.type == :boolean}>boolean</option>
        <option selected={@variable.type == :integer}>integer</option>
        <option selected={@variable.type == :string}>string</option>
        <option selected={@variable.type == :date}>date</option>
        <option selected={@variable.type == :map}>map</option>
      </select>
      <div class="h-2" />
      <%= if @variable.type == :string do %>
        <div class="text-sm my-1">
          Allowed values
        </div>
        <%= for allowed_value <- @variable.enum do %>
          <div class="inline-block border mr-1 mb-1 pl-2">
            <%= allowed_value %>
            <button class="btn">x</button>
          </div>
        <% end %>
        <div>
          <div class="inline-block border mr-1 my-1">
            <input class="form-fld w-40" /><button class="btn btn-default">+</button>
          </div>
        </div>
        <div class="h-2" />
      <% end %>
      <div class="text-sm my-1">
        Position
      </div>
      <select class="form-fld w-full">
        <option selected={Variable.input?(@variable)}>input</option>
        <option selected={Variable.output?(@variable)}>output</option>
        <option selected={!Variable.input?(@variable) && !Variable.output?(@variable)}>intermediate</option>
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
