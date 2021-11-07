defmodule VacEngineWeb.Editor.VariableComponent do
  use Phoenix.Component

  def render(assigns) do
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
end
