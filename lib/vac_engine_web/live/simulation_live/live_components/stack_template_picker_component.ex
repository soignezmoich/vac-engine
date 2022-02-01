defmodule StackTemplatePickerComponent do
  use VacEngineWeb, :live_component

  import Ecto.Changeset

  alias VacEngine.Simulation
  alias VacEngineWeb.SimulationLive.StackEditorComponent

  def update(
        %{
          stack: stack,
          target_component: target_component,
          template_case: template_case,
          template_names: template_names
        },
        socket
      ) do
    template_case_id =
      case template_case do
        nil -> nil
        template_case -> template_case.id
      end

    types = %{case_id: :integer}

    changeset =
      {%{case_id: template_case_id}, types}
      |> cast(%{}, Map.keys(types))

    IO.inspect(changeset)

    socket =
      socket
      |> assign(
        stack: stack,
        changeset: changeset,
        target_component: target_component,
        template_names: template_names
      )

    {:ok, socket}
  end

  def handle_event(
        "set_template",
        %{"layer" => %{"case_id" => template_case_id_string}},
        %{assigns: %{stack: stack, target_component: target_component}} = socket
      ) do
    case template_case_id_string do
      "" ->
        stack |> Simulation.delete_stack_template()

      template_case_id_string ->
        {template_case_id, _binary} = template_case_id_string |> Integer.parse()
        Simulation.set_stack_template(stack, template_case_id)
    end

    send_update(StackEditorComponent,
      id: target_component,
      action: {:refresh, :rand.uniform()}
    )

    {:noreply, socket}
  end
end
