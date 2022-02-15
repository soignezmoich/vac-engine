defmodule VacEngineWeb.SimulationLive.EntryValueFieldComponent do
  use VacEngineWeb, :live_component

  import Ecto.Changeset
  import VacEngine.PipeHelpers

  alias VacEngine.Convert
  alias VacEngine.Repo
  alias VacEngine.Simulation

  def update(
        %{
          id: id,
          input_entry: input_entry,
          target_component: %{type: target_type, id: target_id},
          variable: variable
        },
        socket
      ) do
    changeset =
      input_entry
      |> cast(%{}, [:value])
      |> Map.put(:action, :update)

    socket
    |> assign(
      id: id,
      changeset: changeset,
      input_entry: input_entry,
      parsed_value: nil,
      target_component: %{type: target_type, id: target_id},
      variable: variable
    )
    |> ok()
  end

  def handle_event(
        "validate",
        %{"input_entry" => %{"value" => value}} = params,
        socket
      ) do
    %{variable: variable, input_entry: input_entry} = socket.assigns

    if dropdown?(variable.type, variable.enum) do
      handle_event("submit", params, socket)
    else
      changeset =
        input_entry
        |> cast(params["input_entry"], [:value])
        |> Simulation.validate_input_entry(variable)
        |> Map.put(:action, :update)

      parsed_value =
        case Convert.parse_string(value, variable.type) do
          {:ok, parsed_value} -> parsed_value
          _ -> nil
        end

      socket
      |> assign(changeset: changeset, parsed_value: parsed_value)
      |> noreply()
    end
  end

  def handle_event("submit", %{"input_entry" => %{"value" => value}}, socket) do
    %{
      variable: variable,
      input_entry: input_entry,
      target_component: target_component
    } = socket.assigns

    case Convert.parse_string(value, variable.type) do
      {:error, _error} ->
        {:noreply, socket}

      {:ok, parsed_value} ->
        input_entry
        |> cast(%{"value" => to_string(parsed_value)}, [:value])
        |> Simulation.validate_input_entry(variable)
        |> Repo.update()

        send_update(target_component.type,
          id: target_component.id,
          action: {:refresh, :rand.uniform()}
        )

        {:noreply, socket}
    end
  end

  defp dropdown?(variable_type, variable_enum) do
    case {variable_type, variable_enum} do
      {:boolean, _} -> true
      {:string, enum} when not is_nil(enum) -> true
      _ -> false
    end
  end
end
