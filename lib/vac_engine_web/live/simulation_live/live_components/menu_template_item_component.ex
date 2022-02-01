defmodule VacEngineWeb.SimulationLive.MenuTemplateItemComponent do
  use VacEngineWeb, :live_component

  alias VacEngine.Simulation
  alias VacEngineWeb.SimulationLive.SimulationEditorComponent

  # template_id={template_id}
  # template_name={template_name}
  # selected={@has_selection && template_id == @selected_id}

  def mount(socket) do
    socket = socket |> assign(error_message: nil)
    {:ok, socket}
  end

  def update(%{action: :hide_error}, socket) do
    socket = socket |> assign(error_message: nil)
    {:ok, socket}
  end

  def update(
        %{
          template_id: template_id,
          template_name: template_name,
          selected: selected
        },
        socket
      ) do
    socket =
      socket
      |> assign(
        template_id: template_id,
        template_name: template_name,
        selected: selected
      )

    {:ok, socket}
  end

  def handle_event("select_item", _params, socket) do
    send_update(SimulationEditorComponent,
      id: "simulation_editor",
      action: :set_selection,
      selected_type: :template,
      selected_id: socket.assigns.template_id
    )

    {:noreply, socket}
  end

  def handle_event("delete_template", _params, socket) do
    %{template_id: template_id} = socket.assigns

    socket =
      case Simulation.delete_template(template_id) do
        {:ok, _} ->
          send_update(SimulationEditorComponent,
            id: "simulation_editor",
            action: :refresh_after_delete_template,
            template_id: template_id
          )

          socket

        {:error, message} ->
          send_update_after(
            VacEngineWeb.SimulationLive.MenuTemplateItemComponent,
            [id: "menu_template_item_#{template_id}", action: :hide_error],
            2000
          )

          socket |> assign(error_message: message)
      end

    {:noreply, socket}
  end
end
