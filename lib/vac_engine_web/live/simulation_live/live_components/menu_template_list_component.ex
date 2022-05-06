defmodule VacEngineWeb.SimulationLive.MenuTemplateListComponent do
  @moduledoc false

  use VacEngineWeb, :live_component

  import VacEngine.PipeHelpers

  alias VacEngine.Simulation
  alias VacEngineWeb.SimulationLive.SimulationEditorComponent
  alias VacEngineWeb.SimulationLive.MenuTemplateItemComponent

  def update(
        %{
          blueprint: blueprint,
          id: id,
          selected_id: selected_id,
          selected_type: selected_type,
          template_names: template_names
        },
        socket
      ) do
    socket
    |> assign(
      id: id,
      blueprint: blueprint,
      template_names: template_names,
      selected_id: selected_id,
      has_selection: selected_type == :template,
      creation_error_message: nil
    )
    |> ok()
  end

  def handle_event("validate", _params, socket) do
    socket
    |> assign(creation_error_message: nil)
    |> noreply()
  end

  def handle_event("create", %{"create_template" => %{"name" => name}}, socket) do
    case Simulation.create_blank_template(socket.assigns.blueprint, name) do
      {:ok, new_template} ->
        send_update(
          SimulationEditorComponent,
          id: "simulation_editor",
          action: :set_selection,
          selected_type: :template,
          selected_id: new_template.id
        )

        socket
        |> noreply()

      {:error, :case, _changeset, _} ->
        socket
        |> assign(
          creation_error_message:
            "invalid name: use only digits, letters, '-' or '_' and start with a letter."
        )
        |> noreply()
    end
  end
end
