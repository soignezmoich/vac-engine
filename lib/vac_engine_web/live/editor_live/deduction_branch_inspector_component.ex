defmodule VacEngineWeb.EditorLive.DeductionBranchInspectorComponent do
  @moduledoc false

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
        socket
        |> assign(changeset: changeset)
        |> noreply()
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
    |> noreply()
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
    |> noreply()
  end
end
