defmodule VacEngineWeb.Editor.VariableComponent do
  use Phoenix.Component

  def render(assigns) do
    # prefix={@path |> Enum.drop(-1) |> Enum.drop(2)}

    assigns =
      assign(
        assigns,
        path: assigns.path,
        renderable:
          build_renderable(
            assigns.variable,
            assigns.path,
            assigns.even,
            assigns.selection_path
          )
      )

    ~H"""
    <tr id={@path}
      class={"#{@renderable.row_class}"}
      phx-value-path={@renderable.dot_path}
      phx-click={"select_variable"}
      phx-target={"#variable_editor"}>
      <td class="px-2">
        <div class="mx-1 whitespace-nowrap">
            <%= @renderable.indentation %><%= @renderable.name %>
        </div>
      </td>
      <td class="px-2">
        <div>
          <%= @renderable.type %><%= @renderable.required %>
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

  def build_renderable(variable, path, even, selection_path) do
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

    dot_path = path |> Enum.join(".")

    selected = "bg-pink-600 text-white"

    unselected_color =
      if variable.mapping == "output" do
        "bg-blue-200"
      else
        "bg-cream-200"
      end

    unselected_opacity =
      if even do
        "bg-opacity-30"
      else
        "bg-opacity-50"
      end

    unselected = "#{unselected_color} #{unselected_opacity}"

    row_class =
      if selection_path == dot_path do
        selected
      else
        unselected
      end

    %{
      name: variable.name,
      type: variable.type,
      indentation: indentation,
      required: required,
      enum: enum,
      row_class: row_class,
      dot_path: dot_path
    }
  end
end
