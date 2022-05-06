defmodule VacEngineWeb.SimulationLive.CaseNameComponent do
  @moduledoc false

  use VacEngineWeb, :live_component

  import Ecto.Changeset
  import VacEngine.PipeHelpers

  alias VacEngine.Repo
  alias VacEngine.Simulation.Case

  def update(
        %{case: %Case{} = kase, target_components: target_components},
        socket
      ) do
    changeset =
      kase
      |> cast(%{}, [:name])
      |> Map.put(:action, :update)

    socket
    |> assign(
      changeset: changeset,
      target_components: target_components,
      case: kase
    )
    |> ok()
  end

  def handle_event("validate", params, socket) do
    changeset =
      socket.assigns.case
      |> cast(params["case"], [:name])
      |> validate_required([:name])
      |> validate_length(:name, min: 1)
      |> Map.put(:action, :update)

    socket
    |> assign(changeset: changeset)
    |> noreply()
  end

  def handle_event("submit", params, %{assigns: assigns} = socket) do
    update_result =
      assigns.case
      |> cast(params["case"], [:name])
      |> validate_required([:name])
      |> validate_length(:name, min: 1)
      |> check_constraint(:name, name: "simulation_cases_name_format")
      |> Repo.update()

    case update_result do
      {:error, changeset} ->
        socket
        |> assign(changeset: changeset)
        |> noreply()

      _ ->
        send_updates(socket, params["case"]["name"])

        socket
        |> noreply()
    end
  end

  defp send_updates(socket, name) do
    for component <- socket.assigns.target_components do
      send_update(component.type,
        id: component.id,
        action: {:refresh, name}
      )
    end

    socket
  end
end
