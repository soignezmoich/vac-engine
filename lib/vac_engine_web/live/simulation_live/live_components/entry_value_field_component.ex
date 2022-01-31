defmodule VacEngineWeb.SimulationLive.EntryValueFieldComponent do
  use VacEngineWeb, :live_component

  import Ecto.Changeset

  alias VacEngine.Convert
  alias VacEngine.Repo

  def update(
        %{
          id: id,
          input_entry: input_entry,
          target_component: %{type: target_type, id: target_id},
          variable_type: variable_type,
          variable_enum: variable_enum
        },
        socket
      ) do
    changeset =
      input_entry
      |> cast(%{}, [:value])
      |> Map.put(:action, :update)

    {
      :ok,
      socket
      |> assign(
        id: id,
        changeset: changeset,
        input_entry: input_entry,
        parsed_value: nil,
        target_component: %{type: target_type, id: target_id},
        variable_enum: variable_enum,
        variable_type: variable_type
      )
    }
  end

  def handle_event("validate", params, socket) do
    if dropdown?(socket.assigns.variable_type, socket.assigns.variable_enum) do
      handle_event("submit", params, socket)
    else
      variable_type = socket.assigns.variable_type

      changeset =
        socket.assigns.input_entry
        |> cast(params["input_entry"], [:value])
        |> validate_required([:key, :value])
        |> validate_entry_type(variable_type)
        |> validate_entry_enum(Map.get(socket.assigns, :variable_enum))
        |> Map.put(:action, :update)

      parsed_value =
        case Convert.parse_string(params["input_entry"]["value"], variable_type) do
          {:ok, parsed_value} -> parsed_value
          _ -> nil
        end

      {:noreply,
       socket |> assign(changeset: changeset, parsed_value: parsed_value)}
    end
  end

  def handle_event("submit", %{"input_entry" => input_entry}, socket) do
    variable_type = socket.assigns.variable_type

    case Convert.parse_string(input_entry["value"], variable_type) do
      {:error, _error} ->
        {:noreply, socket}

      {:ok, parsed_value} ->
        socket.assigns.input_entry
        |> cast(%{"value" => to_string(parsed_value)}, [:value])
        |> validate_required([:key, :value])
        |> validate_entry_type(variable_type)
        |> validate_entry_enum(Map.get(socket.assigns, :variable_enum))
        |> Repo.update()

        send_update(socket.assigns.target_component.type,
          id: socket.assigns.target_component.id,
          action: {:refresh, :rand.uniform()}
        )

        {:noreply, socket}
    end
  end

  defp validate_entry_type(entry_changeset, variable_type) do
    validate_change(
      entry_changeset,
      :value,
      "not parsable as #{variable_type}",
      fn _field, value ->
        case Convert.parse_string(value, variable_type) do
          {:error, error} -> [{:value, error}]
          _ -> []
        end
      end
    )
  end

  defp validate_entry_enum(entry_changeset, variable_enum) do
    if variable_enum do
      entry_changeset
      |> validate_inclusion(:value, variable_enum, message: "not in enum")
    else
      entry_changeset
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
