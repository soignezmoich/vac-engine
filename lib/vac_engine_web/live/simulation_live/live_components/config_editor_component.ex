defmodule VacEngineWeb.SimulationLive.ConfigEditorComponent do
  @moduledoc """

  """

  use VacEngineWeb, :live_component

  import Ecto.Changeset

  alias VacEngine.Convert
  alias VacEngine.Simulation

  def update(%{blueprint: blueprint}, socket) do
    setting =
      case Simulation.get_setting(blueprint) do
        nil -> Simulation.create_setting(blueprint)
        setting -> setting
      end

    changeset =
      setting
      |> cast(%{}, [:env_now])
      |> Map.put(:action, :update)

    socket =
      socket
      |> assign(
        blueprint: blueprint,
        changeset: changeset,
        parsed_value: nil,
        setting: setting
      )

    {:ok, socket}
  end


  def handle_event("validate", %{"setting" => %{"env_now" => env_now}}, socket) do
    %{setting: setting} = socket.assigns

    # Recompute changeset (validation) from the original setting
    changeset =
      setting
      |> cast(%{env_now: env_now}, [:env_now])
      |> Simulation.validate_setting()
      |> Map.put(:action, :update)

    # Parse the user input as datetime
    parsed_value =
      try do
        case Convert.parse_string(env_now, :datetime) do
          {:ok, parsed_value} -> parsed_value
          _error -> nil
        end
      rescue
        _error -> nil
      end

    {:noreply,
     socket |> assign(changeset: changeset, parsed_value: parsed_value)}
  end


  def handle_event("submit", %{"setting" => %{"env_now" => env_now}}, socket) do
    %{setting: setting} = socket.assigns

    try do
      case Convert.parse_string(env_now, :datetime) do
        {:error, _error} ->
          {:noreply, socket}

        {:ok, parsed_value} ->
          setting
          |> Simulation.update_setting(env_now: parsed_value)

          setting =
            case Simulation.get_setting(socket.assigns.blueprint) do
              nil -> Simulation.create_setting(socket.assigns.blueprint)
              setting -> setting
            end

          changeset =
            setting
            |> cast(%{}, [:env_now])
            |> Map.put(:action, :update)

            send_update(VacEngineWeb.SimulationLive.SimulationEditorComponent,
              id: "simulation_editor",
              action: :update_all_results
            )

          {:noreply,
           socket
           |> assign(
             changeset: changeset,
             parsed_value: parsed_value,
             setting: setting
           )}
      end



    rescue
      # TODO replace when timex doesn't raise an error anymore when "2000-"
      _error ->
        {:error, "not a valid date"}
    end
  end
end
