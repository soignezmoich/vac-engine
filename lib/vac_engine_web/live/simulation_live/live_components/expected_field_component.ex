defmodule VacEngineWeb.SimulationLive.ExpectedFieldComponent do
  @moduledoc false

  use VacEngineWeb, :live_component

  import Ecto.Changeset
  import VacEngine.PipeHelpers

  alias VacEngine.Convert
  alias VacEngine.Repo

  def update(
        %{
          id: id,
          output_entry: output_entry,
          target_component: %{type: target_type, id: target_id},
          variable_type: variable_type,
          variable_enum: variable_enum
        },
        socket
      ) do
    changeset =
      output_entry
      |> cast(%{}, [:expected])
      |> Map.put(:action, :update)

    socket
    |> assign(
      id: id,
      changeset: changeset,
      output_entry: output_entry,
      parsed_value: nil,
      target_component: %{type: target_type, id: target_id},
      variable_enum: variable_enum,
      variable_type: variable_type
    )
    |> ok()
  end

  def handle_event("validate", params, socket) do
    if dropdown?(socket.assigns.variable_type, socket.assigns.variable_enum) do
      handle_event("submit", params, socket)
    else
      variable_type = socket.assigns.variable_type

      changeset =
        socket.assigns.output_entry
        |> cast(params["output_entry"], [:expected])
        |> validate_required([:key, :expected])
        |> validate_entry_type(variable_type)
        |> validate_entry_enum(Map.get(socket.assigns, :variable_enum))
        |> Map.put(:action, :update)

      parsed_value =
        case Convert.parse_string(
               params["output_entry"]["expected"],
               variable_type
             ) do
          {:ok, parsed_value} -> parsed_value
          _ -> nil
        end

      socket
      |> assign(changeset: changeset, parsed_value: parsed_value)
      |> noreply()
    end
  end

  def handle_event(
        "submit",
        %{"output_entry" => output_entry},
        %{assigns: assigns} = socket
      ) do
    variable_type = assigns.variable_type

    case Convert.parse_string(output_entry["expected"], variable_type) do
      {:error, _error} ->
        {:noreply, socket}

      {:ok, parsed_value} ->
        assigns.output_entry
        |> cast(%{"expected" => to_string(parsed_value)}, [:expected])
        |> validate_required([:key, :expected])
        |> validate_entry_type(variable_type)
        |> validate_entry_enum(Map.get(assigns, :variable_enum))
        |> Repo.update()

        %{type: type, id: id} = assigns.target_component

        send_update(type,
          id: id,
          action: {:refresh, :rand.uniform()}
        )

        {:noreply, socket}
    end
  end

  defp validate_entry_type(entry_changeset, variable_type) do
    validate_change(
      entry_changeset,
      :expected,
      "not parsable as #{variable_type}",
      fn _field, expected ->
        case Convert.parse_string(expected, variable_type) do
          {:error, error} -> [{:expected, error}]
          _ -> []
        end
      end
    )
  end

  defp validate_entry_enum(entry_changeset, variable_enum) do
    if variable_enum do
      entry_changeset
      |> validate_inclusion(:expected, variable_enum, message: "not in enum")
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
