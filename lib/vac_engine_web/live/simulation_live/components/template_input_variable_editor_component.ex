defmodule VacEngineWeb.SimulationLive.TemplateInputVariableEditorComponent do
  use Phoenix.Component

  import VacEngine.SimulationHelpers
  import VacEngineWeb.IconComponent
  import VacEngineWeb.SimulationLive.InputComponent

  def render(assigns) do

    template_value = assigns.template.input |> get_value(assigns.variable.path)

    assigns = assign(assigns, template_value: template_value)

    ~H"""
    <%= if @variable.mapping == :in_required || !is_nil(@template_value) do %>
      <.render_present variable={@variable} value={@template_value} />
    <% else %>
      <.render_absent variable={@variable} />
    <% end %>
    """
  end

  defp render_absent(assigns) do
    ~H"""
    <tr>
      <td class="pr-3 text-purple-700">
        <span class="text-xs hover:text-purple-400"><.icon name="toggle-off" width="2rem"/></span>
      </td>
      <td>
        <%= @variable.path |> Enum.drop(-1) |> Enum.map(&("\u2574" || &1)) %>
        <%= @variable.name %>
      </td>
      <td>
        <div class="inline-block form-fld invisible">
          placeholder
        </div>
      </td>
      <td class="w-full" />
    </tr>
    """
  end

  defp render_present(assigns) do

    ~H"""
    <tr class="bg-purple-50">
      <td class="pr-3 text-purple-700">
        <span class="text-xs hover:text-purple-400"><.icon name="toggle-on" width="2rem"/></span>
      </td>
      <td>
        <%= @variable.path |> Enum.drop(-1) |> Enum.map(&("\u2574" || &1)) %>
        <span><%= @variable.name %></span>
      </td>
      <td class="pl-2">
        <%= case @variable.type do %>
        <% :boolean -> %>
          <.boolean_input value={@value} />
        <% :number -> %>
          <.number_input value={@value} />
        <% :integer -> %>
          <.integer_input value={@value} />
        <% :string -> %>
          <.string_input enum={@variable.enum} value={@value} />
        <% :date -> %>
          <.date_input value={@value} />
        <% :datetime -> %>
          <.datetime_input value={@value} />
        <% :map -> %>
          <div class="inline-block form-fld invisible">
            placeholder
          </div>
        <% end %>
      </td>
      <td class="w-full" />
    </tr>
    """
  end

end
