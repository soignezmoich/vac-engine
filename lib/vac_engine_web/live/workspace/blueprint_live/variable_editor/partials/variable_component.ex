defmodule VacEngineWeb.Editor.VariableComponent do
  use Phoenix.Component

  def variable(assigns) do
    # prefix={@path |> Enum.drop(-1) |> Enum.drop(2)}

    assigns =
      assign(
        assigns,
        path: assigns.path,
        renderable: build_renderable(assigns.variable, assigns.path)
      )

    ~H"""
    <% color = if @mapping == "output" do "bg-blue-200" else "bg-cream-200" end %>
    <% opacity = if @even do "bg-opacity-30" else "bg-opacity-50" end %>
    <tr id={@path} class={"#{color} #{opacity}"}>
      <td class="px-2">
        <div class="mx-1 whitespace-nowrap">
            <%= @renderable.indentation %><%= @renderable.name %>
        </div>
      </td>
      <td class="px-2">
        <div>
          <%= @renderable.type %><span class="text-red-500 font-bold"><%= @renderable.required %></span>
        </div>
      </td>
      <td class="px-2">
        <div>
          <%= @renderable.enum %>
        </div>
      </td>
    </tr>
    """
  end


  def build_renderable(variable, path) do
    indentation =
      path
      # remove root of the path until variable tree
      |> Enum.drop(2)
      # remove variable name
      |> Enum.drop(-1)
      # turn the variable parents into indentation
      |> Enum.map(fn _ -> "- - " end)
      |> Enum.join()

    required =
      case variable.mapping do
        :in_required -> "*"
        _ -> ""
      end

    enum =
      case variable do
        %{enum: nil} -> []
        %{enum: enum} -> enum
        _ -> []
      end
      |> Enum.join(", ")

    %{
      name: variable.name,
      type: variable.type,
      indentation: indentation,
      required: required,
      enum: enum
    }
  end

  def dot_name_input(assigns) do
    ~H"""
    <div class="mx-1 whitespace-nowrap">
        <%= @text %><%= @required_indication %>
    </div>
    """
  end

  def type_input(%{variable: %{type: :map}} = assigns) do
    ~H"""
    """
  end

  def type_input(%{variable: %{type: _}} = assigns) do
    ~H"""
      <div>
        <%= @variable.type %>
      </div>
    """
  end

  def type_input(assigns) do
    ~H"""
      unknown_type:<%= inspect(assigns.variable) %>
    """
  end

  def in_out(assigns) do
    dot_path =
      assigns.path
      |> Enum.reverse()
      |> Enum.join(".")

    assigns =
      assign(assigns, %{
        dot_path: dot_path,
        # variable.<variable_name>.in_out
        is_root: Enum.count(assigns.path) == 3
      })

    ~H"""
    <%= if @is_root do %>
      <form phx-change="save_in_out" class="mx-1">
        <input type="hidden" name="path" value={@dot_path} />
        <select name="in_out" class="bg-white form-fld mb-1" >
          <option value="input" selected={@is_input}>input</option>
          <option value="output" selected={!@is_input && @is_output}>output</option>
          <option value="intermediate" selected={!@is_input && !@is_output}>intermediate</option>
        </select>
      </form>
    <% end %>
    """
  end

  def common_values(assigns) do
    ~H"""
      <div>
        <%= @values |> Enum.join(", ") %>
      </div>
    """
  end
end
