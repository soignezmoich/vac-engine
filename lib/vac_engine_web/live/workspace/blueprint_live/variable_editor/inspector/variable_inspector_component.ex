defmodule VacEngineWeb.Editor.VariableInspectorComponent do
  use Phoenix.Component

  import VacEngineWeb.ToggleComponent

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
      <%
        containers = case {Variable.input?(@variable), Variable.output?(@variable)} do
          {true, _} -> @input_containers
          {false, false} -> @intermediate_containers
          {_, true} -> @output_containers
        end
        variable_container_path = @variable.path |> Enum.drop(-1)
      %>
      <select class="form-fld w-full">
        <option value=""><%="<root>"%></option>
        <%= for container <- containers do %>
          <% dot_path = container.path |> Enum.join(".") %>
          <option value={dot_path} selected={variable_container_path == container.path}>
            <%=  dot_path %>
          </option>
        <% end %>
      </select>
      <div class="h-2" />
      <div class="text-sm my-1">
        Type
      </div>
      <select class="form-fld w-full">
        <option value={:boolean} selected={@variable.type == :boolean}>boolean</option>
        <option value={:integer} selected={@variable.type == :integer}>integer</option>
        <option value={:number} selected={@variable.type == :number}>number</option>
        <option value={:string} selected={@variable.type == :string}>string</option>
        <option value={:date} selected={@variable.type == :date}>date</option>
        <option value={:datetime} selected={@variable.type == :datetime}>datetime</option>
        <option value={:map} selected={@variable.type == :map}>map</option>
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
      <%= if Variable.input?(@variable) do %>
        <div class="text-sm my-1">
          Required?
        </div>
        <div class="w-20">
          <.toggle
            value={Variable.required?(@variable)}
            click="toggle_required"
            id={'#{@variable.path |> Enum.join(".")}.toggle_required'}
          confirm />
        </div>
        <div class="h-2" />
        <div class="grid grid-cols-2 gap-1.5 mt-1">
          <button class="btn">Cancel</button>
          <button class="btn btn-default">Save</button>
        </div>
      <% end %>
    </div>
    """
  end

  defp name_editor do

  end
end
