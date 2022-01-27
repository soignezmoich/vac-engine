defmodule VacEngineWeb.EditorLive.DeductionBranchInspectorComponent do
  use VacEngineWeb, :live_component

  import VacEngine.PipeHelpers
  alias VacEngine.Processor

  @impl true
  def update(%{branch: branch}, socket) do
    changeset =
      branch
      |> Processor.change_branch()
      |> Map.put(:action, :insert)

    socket
    |> assign(changeset: changeset, branch: branch)
    |> ok()
  end

  @impl true
  def handle_event(
        "save",
        %{"branch" => params},
        %{assigns: %{branch: branch}} = socket
      ) do
    Processor.update_branch(branch, params)
    |> case do
      {:ok, _} ->
        send(self(), :reload_blueprint)
        {:noreply, socket}

      {:error, changeset} ->
        IO.inspect(changeset)
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_event(
        "validate",
        %{"branch" => params},
        %{assigns: %{branch: branch}} = socket
      ) do
    changeset =
      branch
      |> Processor.change_branch(params)
      |> Map.put(:action, :insert)

    socket
    |> assign(changeset: changeset)
    |> pair(:noreply)
  end

  @impl true
  def handle_event(
        "cancel",
        _,
        %{assigns: %{branch: branch}} = socket
      ) do
    changeset =
      branch
      |> Processor.change_branch()
      |> Map.put(:action, :insert)

    socket
    |> assign(changeset: changeset)
    |> pair(:noreply)
  end
end
