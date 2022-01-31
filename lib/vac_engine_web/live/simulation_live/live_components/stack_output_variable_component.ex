defmodule VacEngineWeb.SimulationLive.StackOutputVariableComponent do
  use VacEngineWeb, :live_component

  import VacEngine.SimulationHelpers
  import VacEngineWeb.SimulationLive.InputComponent
  import VacEngineWeb.IconComponent


  alias VacEngine.Simulation
  alias VacEngineWeb.SimulationLive.StackEditorComponent
  alias VacEngineWeb.SimulationLive.ToggleEntryComponent
  alias VacEngineWeb.SimulationLive.ToggleForbiddenComponent

  # def update(assigns, socket) do
  #   expected =
  #     Map.get(assigns.case, :expect, %{})
  #     |> get_value(assigns.variable.path)

  #   forbidden =
  #     Map.get(assigns.case, :forbid, %{})
  #     |> variable_forbidden?(assigns.variable.path)

  #   actual =
  #     Map.get(assigns.case, :actual, %{})
  #     |> get_value(assigns.variable.path)

  #   mismatch = check_mismatch?({expected, forbidden, actual})

  #   socket =
  #     socket
  #     |> assign(assigns)
  #     |> assign(
  #       expected: expected,
  #       forbidden: forbidden,
  #       actual: actual,
  #       mismatch: mismatch
  #     )

  #   {:ok, socket}
  # end

  def update(
        %{
          id: id,
          filter: filter,
          runnable_case: runnable_case,
          stack: stack,
          variable: variable
        },
        socket
      ) do
    runnable_output_entry =
      runnable_case.output_entries
      |> Enum.find(&(&1.key == variable.path |> Enum.join(".")))

    {expected, forbidden} =
      case runnable_output_entry do
        nil ->
          {nil, false}

        _existing ->
          case runnable_output_entry.expected do
            nil -> {nil, true}
            expected -> {expected, false}
          end
      end

    actual = "bla"

    mismatch =
      case {expected, actual, forbidden} do
        {_, actual, true} when not is_nil(actual) -> true
        {_, actual, true} when is_nil(actual) -> false
        {nil, _, false} -> false
        {expected, actual, false} when expected == actual -> false
        _ -> true
      end

    IO.inspect(runnable_output_entry)

    bg_color =
      case {mismatch, runnable_output_entry} do
        {true, _} -> "bg-red-100"
        {false, nil} -> ""
        _ -> "bg-purple-100"
      end

    active = !is_nil(runnable_output_entry)

    visible =
      active ||
        filter == "all"

    socket =
      socket
      |> assign(
        active: active,
        actual: "bla",
        expected: expected,
        forbidden: forbidden,
        id: id,
        bg_color: bg_color,
        filter: filter,
        mismatch: mismatch,
        runnable_case: runnable_case,
        runnable_output_entry: runnable_output_entry,
        stack: stack,
        variable: variable,
        visible: visible
      )

    {:ok, socket}
  end


  def handle_event("toggle_entry", %{"active" => active}, socket) do
    %{
      runnable_case: runnable_case,
      stack: stack,
      runnable_output_entry: runnable_output_entry,
      variable: variable
    } = socket.assigns

    if active == "true" do
      type = variable.type
      enum = Map.get(variable, :enum)

      entry_key = variable.path |> Enum.join(".")

      {:ok, input_entry} =
        Simulation.create_output_entry(
          runnable_case,
          entry_key,
          Simulation.variable_default_value(type, enum)
        )

      input_entry
    else
      Simulation.delete_output_entry(runnable_output_entry)
      nil
    end

    send_update(StackEditorComponent,
      id: "stack_editor_#{stack.id}",
      action: {:refresh, :rand.uniform()}
    )

    {:noreply, socket}
  end
end

# <%# <div  class={"table-row"}>
#   <%= case {@expected, @forbidden} do %>
#     <% {expected, forbidden} when not is_nil(expected) or forbidden -> %>
#       <div class="table-cell pr-3 text-purple-700">
#         <span class="text-xs hover:text-purple-400"><.icon name="toggle-on" width="2rem"/></span>
#       </div>
#       <div class="table-cell">
#         <%= @variable.path |> Enum.drop(-1) |> Enum.map(fn _ -> "\u2574" end) %><%= @variable.name %>
#       </div>
#       <%= if @forbidden do %>
#         <div class={"table-cell pl-2 text-red-500"}>
#           <span class="text-xs hover:text-red-300"><.icon name="hero/ban" width="1.6rem"/></span>
#         </div>
#         <div/>
#       <% else %>
#         <div class={"table-cell pl-2 text-gray-300"}>
#           <span class="text-xs hover:text-red-300"><.icon name="hero/ban" width="1.6rem"/></span>
#         </div>
#         <div class="table-cell pl-2">
#           blabla
#         </div>
#       <% end %>
#       <div class="table-cell w-full">
#         <%= if is_nil(@actual) do %>
#           -
#         <% else %>
#           <%= if @variable.type == :map do %>
#             <.icon name="hero/sort-descending" width="1.25rem" />
#           <% else %>
#             <%= inspect(@actual) %>
#           <% end %>
#         <% end %>
#       </div>
#     <% _ -> %>
#       <div class="table-cell pr-3 text-purple-700">
#         <span class="text-xs hover:text-purple-400"><.icon name="toggle-off" width="2rem"/></span>
#       </div>
#       <div class="table-cell">
#         <%= @variable.path |> Enum.drop(-1) |> Enum.map(fn _ -> "\u2574" end) %><%= @variable.name %>
#       </div>
#       <div class="table-cell"/>
#       <div class="table-cell">
#         <div class="inline-block form-fld invisible">
#           placeholder
#         </div>
#       </div>
#       <div class="table-cell w-full">
#         <%= if is_nil(@actual) do %>
#           -
#         <% else %>
#           <%= if @variable.type == :map do %>
#             <.icon name="hero/sort-descending" width="1.25rem" />
#           <% else %>
#             <%= inspect(@actual) %>
#           <% end %>
#         <% end %>
#       </div>
#   <% end %>
# </div> %>
