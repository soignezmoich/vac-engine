defmodule VacEngineWeb.BlueprintLive.New do
  @moduledoc """
  The new blueprint creation page.
  """

  use VacEngineWeb, :live_view

  import VacEngine.PipeHelpers
  import VacEngineWeb.PermissionHelpers, only: [can!: 3]

  alias VacEngine.Processor
  alias VacEngine.Processor.Blueprint

  on_mount(VacEngineWeb.LiveRole)
  on_mount(VacEngineWeb.LiveWorkspace)
  on_mount({VacEngineWeb.LiveLocation, ~w(blueprint new)a})

  @impl true
  def mount(_params, _session, %{assigns: %{workspace: workspace}} = socket) do
    can!(socket, :write_blueprints, workspace)

    changeset =
      %Blueprint{}
      |> Processor.change_blueprint()
      |> Map.put(:action, :insert)

    socket
    |> assign(changeset: changeset)
    |> ok()
  end

  @impl true
  def handle_params(_params, _session, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "validate",
        %{"blueprint" => params},
        socket
      ) do
    changeset =
      %Blueprint{}
      |> Processor.change_blueprint(params)
      |> Map.put(:action, :insert)

    socket
    |> assign(changeset: changeset)
    |> noreply()
  end

  @impl true
  def handle_event(
        "create",
        %{"blueprint" => params},
        %{assigns: %{workspace: workspace}} = socket
      ) do
    can!(socket, :write_blueprints, workspace)

    Processor.create_blueprint(workspace, params)
    |> case do
      {:ok, br} ->
        socket
        |> push_redirect(
          to:
            Routes.workspace_blueprint_path(
              socket,
              :summary,
              workspace.id,
              br.id
            )
        )
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(changeset: changeset)
        |> noreply()
    end
  end
end
