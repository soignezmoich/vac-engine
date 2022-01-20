defmodule VacEngineWeb.SimulationLive.CaseInputVariableEditorComponent do
  use Phoenix.Component

  import VacEngine.SimulationHelpers
  import VacEngineWeb.SimulationLive.InputComponent
  import VacEngineWeb.IconComponent

  alias VacEngineWeb.SimulationLive.ToggleEntryComponent

  def render(assigns) do
    case_value =
      assigns.case.input
      |> get_value(assigns.variable.path)

    template_value =
      assigns.template.input
      |> get_value(assigns.variable.path)

    assigns =
      assign(assigns, case_value: case_value, template_value: template_value)

    ~H"""
    <%= if !is_nil(@case_value) do %>
      <.render_present_in_case variable={@variable} value={@case_value} />
    <% else %>
      <%= if !is_nil(@template_value) do %>
        <.render_present_in_template variable={@variable} value={@template_value} filter={@filter} />
      <% else %>
        <.render_absent variable={@variable} filter={@filter} />
      <% end %>
    <% end %>
    """
  end

  defp render_absent(assigns) do
    if assigns.filter == "all" do
      ~H"""
      <tr>
        <td class="pr-3 text-purple-700">
          <ToggleEntryComponent.render active={false} target_component={"##{@variable.name}"} />
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
    else
      ~H"""
      """
    end
  end

  defp render_present_in_case(assigns) do
    ~H"""
    <tr class="bg-purple-100">

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

  defp render_present_in_template(assigns) do
    if assigns.filter != "case" do
      ~H"""
      <tr class="bg-purple-50">
        <td class="pr-3 text-purple-700">
          <span class="text-xs hover:text-purple-400"><.icon name="toggle-off" width="2rem"/></span>
        </td>
        <td>
          <%= @variable.path |> Enum.drop(-1) |> Enum.map(&("\u2574" || &1)) %>
          <span><%= @variable.name %></span>
        </td>
        <td class="pl-2">
          <%= if @variable.type != :map do %>
            <%= inspect(@value) %>
          <% end %>
        </td>
        <td class="w-full" />
      </tr>
      """
    else
      ~H"""
      """
    end
  end
end
