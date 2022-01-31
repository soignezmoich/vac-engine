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

    template_case_id = case template_case do
      nil -> nil
      template_case -> template_case.id
    end

    types = %{case_id: :integer}

    changeset =
      {%{case_id: template_case_id}, types}
      |> cast(%{}, Map.keys(types))

    {:ok,
     socket
     |> assign(
       stack: stack,
       changeset: changeset,
       target_component: target_component,
       template_names: template_names
     )}
  end

  def handle_event(
        "set_template",
        %{"layer" => %{"case_id" => template_id_string}},
        %{assigns: %{stack: stack, target_component: target_component}} = socket
      ) do
    case template_id_string do
      "" ->
        IO.puts("none")
        stack |> Simulation.delete_stack_template()
      template_id_string ->
        {template_id, _binary} = template_id_string |> Integer.parse()
        Simulation.set_stack_template(stack, template_id)
    end


    send_update(StackEditorComponent,
      id: target_component,
      action: {:refresh, :rand.uniform()}
    )

    {:noreply, socket}
  end
end
