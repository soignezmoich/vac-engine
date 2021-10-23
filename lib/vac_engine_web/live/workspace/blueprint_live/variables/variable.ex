defmodule VacEngineWeb.Editor.Variable do
  use Phoenix.Component

  def variable(assigns) do
    enum =
      case assigns.variable do
        %{enum: nil} -> []
        %{enum: enum} -> enum
        _ -> []
      end

    assigns =
      assign(assigns, %{
        enum: enum
      })

    ~H"""
    <% color = if @in_out == "output" do "bg-blue-200" else "bg-cream-200" end %>
    <% opacity = if @even do "bg-opacity-30" else "bg-opacity-50" end %>
    <tr id={@variable.path} class={"#{color} #{opacity}"}>
      <td class="px-2">
        <.dot_name_input
          variable={@variable}
          prefix={@variable.path |> Enum.drop(-1) |> Enum.drop(1)} />
      </td>
      <td class="px-2">
        <.type_input
          variable={@variable} />
      </td>
      <td class="px-2">
        <.common_values
        values={@variable.enum} />
      </td>
    </tr>
    """
  end

  def dot_name_input(assigns) do
    indents =
      assigns.prefix
      |> Enum.map(fn _ -> "- - " end)

    blurred_content =
      [assigns.variable.name | indents]
      |> Enum.reverse()
      |> Enum.join("")

    assigns =
      assign(assigns, %{
        blurred_content: blurred_content
      })

    ~H"""
    <div class="mx-1 whitespace-nowrap">
        <%= @blurred_content %>
    </div>
    """
  end

  def type_input(assigns) do
    ~H"""
    <%= if @variable.type != :map do %>
        <div>
          <%= @variable.type %>
        </div>
    <% end %>
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
