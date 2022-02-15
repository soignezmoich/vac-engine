defmodule VacEngineWeb.SimulationLive.ConfigEditorComponent do
  @moduledoc """

  """

  use VacEngineWeb, :live_component

  import Ecto.Changeset
  import VacEngine.PipeHelpers

  alias VacEngine.Convert
  alias VacEngine.Simulation
  alias VacEngine.Simulation.Job

  def update(%{blueprint: blueprint}, socket) do
    {:ok, setting} =
      case Simulation.get_setting(blueprint) do
        nil -> Simulation.create_setting(blueprint)
        setting -> {:ok, setting}
      end

    changeset =
      setting
      |> cast(%{}, [:env_now])
      |> Map.put(:action, :update)

    socket
    |> assign(
      blueprint: blueprint,
      changeset: changeset,
      parsed_value: nil,
      setting: setting
    )
    |> ok()
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

    socket
    |> assign(changeset: changeset, parsed_value: parsed_value)
    |> noreply()
  end

  def handle_event("submit", %{"setting" => %{"env_now" => env_now}}, socket) do
    %{blueprint: blueprint, setting: setting} = socket.assigns

    try do
      case Convert.parse_string(env_now, :datetime) do
        {:error, _error} ->
          {:noreply, socket}

        {:ok, parsed_value} ->
          setting
          |> Simulation.update_setting(env_now: parsed_value)

          setting =
            case Simulation.get_setting(blueprint) do
              nil -> Simulation.create_setting(blueprint)
              setting -> setting
            end

          changeset =
            setting
            |> cast(%{}, [:env_now])
            |> Map.put(:action, :update)

          start_all_runner_jobs(blueprint)

          socket
          |> assign(
            changeset: changeset,
            parsed_value: parsed_value,
            setting: setting
          )
          |> noreply()
      end
    rescue
      # TODO replace when timex doesn't raise an error anymore when "2000-"
      _error ->
        {:error, "not a valid date"}
    end
  end

  defp start_all_runner_jobs(blueprint) do
    stacks = Simulation.get_stacks(blueprint)

    stacks
    |> Enum.map(&Job.new(&1))
    |> Enum.map(&Simulation.queue_job(&1))
  end
end
