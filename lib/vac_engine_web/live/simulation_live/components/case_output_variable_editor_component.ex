defmodule VacEngineWeb.SimulationLive.CaseOutputVariableEditorComponent do
  use Phoenix.Component

  import VacEngine.SimulationHelpers
  import VacEngineWeb.SimulationLive.InputComponent
  import VacEngineWeb.IconComponent

  def render(assigns) do

    expected = Map.get(assigns.case, :expect, %{})
      |> get_value(assigns.variable.path)

    forbidden = Map.get(assigns.case, :forbid, %{})
      |> variable_forbidden?(assigns.variable.path)

    actual = Map.get(assigns.case, :actual, %{})
      |> get_value(assigns.variable.path)

    assigns = assign(assigns, expected: expected, forbidden: forbidden, actual: actual)

    ~H"""
    <%= case {@expected, @forbidden} do %>
    <% {expected, forbidden} when not is_nil(expected) or forbidden -> %>
      <.render_present_in_case
        variable={@variable}
        expected={@expected}
        forbidden={@forbidden}
        mismatch={check_mismatch?({@expected, @forbidden, @actual})}
        actual={@actual} />
    <% _ -> %>
      <.render_absent variable={@variable} actual={@actual} filter={@filter} />
    <% end %>
    """
  end

  defp render_map(assigns) do
    ~H"""
    <tr>
      <td class="pr-3 text-purple-700">
      </td>
      <td>
        <%= @variable.path |> Enum.drop(-1) |> Enum.map(&("\u2574" || &1)) %><%= @variable.name %>
      </td>
      <td>
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

  defp render_absent(assigns) do
    if assigns.filter == "all" do
      ~H"""
      <tr>
        <td class="pr-3 text-purple-700">
          <span class="text-xs hover:text-purple-400"><.icon name="toggle-off" width="2rem"/></span>
        </td>
        <td>
          <%= @variable.path |> Enum.drop(-1) |> Enum.map(&("\u2574" || &1)) %><%= @variable.name %>
        </td>
        <td>
        </td>
        <td>
        <div class="inline-block form-fld invisible">
          placeholder
        </div>
        </td>
        <td class="w-full">
          <%= if is_nil(@actual) do %>
            -
          <% else %>
            <%= if @variable.type == :map do %>
              <.icon name="hero/sort-descending" width="1.25rem" />
            <% else %>
              <%= inspect(@actual) %>
            <% end %>
          <% end %>
        </td>
      </tr>
      """
    else
      ~H"""
      """
    end
  end

  defp render_present_in_case(assigns) do
    ~H"""
    <tr class={if @mismatch do "bg-red-200" else "bg-purple-100" end}>
      <td class="pr-3 text-purple-700">
        <span class="text-xs hover:text-purple-400"><.icon name="toggle-on" width="2rem"/></span>
      </td>
      <td>
        <%= @variable.path |> Enum.drop(-1) |> Enum.map(&("\u2574" || &1)) %><%= @variable.name %>
      </td>
      <%= if @forbidden do %>
        <td class={"pl-2 text-red-500"}>
          <span class="text-xs hover:text-red-300"><.icon name="hero/ban" width="1.6rem"/></span>
        </td>
        <td/>
      <% else %>
        <td class={"pl-2 text-gray-300"}>
          <span class="text-xs hover:text-red-300"><.icon name="hero/ban" width="1.6rem"/></span>
        </td>
        <td class="pl-2">
          <%= case @variable.type do %>
          <% :boolean -> %>
            <.boolean_input value={@expected} />
          <% :number -> %>
            <.number_input value={@expected} />
          <% :integer -> %>
            <.integer_input value={@expected} />
          <% :string -> %>
            <.string_input enum={@variable.enum} value={@expected} />
          <% :date -> %>
            <.date_input value={@expected} />
          <% :datetime -> %>
            <.datetime_input value={@expected} />
          <% :map -> %>
            <div class="inline-block form-fld invisible">
              placeholder
            </div>
          <% end %>
        </td>
      <% end %>
      <td class="w-full">
        <%= if is_nil(@actual) do %>
          -
        <% else %>
          <%= if @variable.type == :map do %>
            <.icon name="hero/sort-descending" width="1.25rem" />
          <% else %>
            <%= inspect(@actual) %>
          <% end %>
        <% end %>
      </td>
    </tr>
    """
  end

end
