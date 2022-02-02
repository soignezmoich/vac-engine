defmodule VacEngineWeb.SimulationLive.ConfigEditorComponent do
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
        changeset: changeset,
        parsed_value: nil,
        setting: setting
      )

    {:ok, socket}
  end

  @doc """
  Called when the input changes.
  Recompute the changeset from the original setting asset to generate
  validation errors. Additionnally parse the input as a datetime
  (even if it is done in the validation process) in order to display
  it to the user. Pass both to the socket they can be displayed in the html.
  """
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
          _ -> nil
        end
      rescue
        _ -> nil
      end

    {:noreply,
     socket |> assign(changeset: changeset, parsed_value: parsed_value)}
  end

  @doc """
  Called when the user submits changes. Changes are applied only if the
  parsing of the user input to a date succeeds. Since the submit button is
  displayed
  """
  def handle_event("submit", %{"setting" => %{"env_now" => env_now}}, socket) do
    %{setting: setting} = socket.assigns

    try do
      case Convert.parse_string(env_now, :datetime) do
        {:error, _error} ->
          {:noreply, socket}

        {:ok, parsed_value} ->
          setting
          |> Simulation.update_setting(env_now: parsed_value)

          {:noreply, socket}
      end
    rescue
      _ -> {:error, "not a valid date"}
    end
  end
end
