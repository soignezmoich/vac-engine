defmodule VacEngineWeb.EditorLive.DeductionTableInspectorComponent do
  use VacEngineWeb, :live_component

  import VacEngine.PipeHelpers
  alias VacEngine.Processor

  @impl true
  def update(%{deduction: deduction}, socket) do
    changeset =
      deduction
      |> Processor.change_deduction()
      |> Map.put(:action, :insert)

    socket
    |> assign(changeset: changeset, deduction: deduction)
    |> ok()
  end

  @impl true
  def handle_event(
        "save",
        %{"deduction" => params},
        %{assigns: %{deduction: deduction}} = socket
      ) do
    Processor.update_deduction(deduction, params)
    |> case do
      {:ok, _} ->
        send(self(), :reload_blueprint)
        {:noreply, socket}

      {:error, changeset} ->
        socket
        |> assign(changeset: changeset)
        |> noreply()
    end
  end

  @impl true
  def handle_event(
        "validate",
        %{"deduction" => params},
        %{assigns: %{deduction: deduction}} = socket
      ) do
    changeset =
      deduction
      |> Processor.change_deduction(params)
      |> Map.put(:action, :insert)

    socket
    |> assign(changeset: changeset)
    |> noreply()
  end

  @impl true
  def handle_event(
        "cancel",
        _,
        %{assigns: %{deduction: deduction}} = socket
      ) do
    changeset =
      deduction
      |> Processor.change_deduction()
      |> Map.put(:action, :insert)

    socket
    |> assign(changeset: changeset)
    |> noreply()
  end
end
