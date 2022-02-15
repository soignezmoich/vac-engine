defmodule VacEngineWeb.EditorLive.DeductionColumnInspectorComponent do
  use VacEngineWeb, :live_component

  import VacEngine.PipeHelpers
  alias VacEngine.Processor

  @impl true
  def update(%{column: column}, socket) do
    changeset =
      column
      |> Processor.change_column()
      |> Map.put(:action, :insert)

    socket
    |> assign(changeset: changeset, column: column)
    |> ok()
  end

  @impl true
  def handle_event(
        "save",
        %{"column" => params},
        %{assigns: %{column: column}} = socket
      ) do
    Processor.update_column(column, params)
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
        %{"column" => params},
        %{assigns: %{column: column}} = socket
      ) do
    changeset =
      column
      |> Processor.change_column(params)
      |> Map.put(:action, :insert)

    socket
    |> assign(changeset: changeset)
    |> noreply()
  end

  @impl true
  def handle_event(
        "cancel",
        _,
        %{assigns: %{column: column}} = socket
      ) do
    changeset =
      column
      |> Processor.change_column()
      |> Map.put(:action, :insert)

    socket
    |> assign(changeset: changeset)
    |> noreply()
  end
end
