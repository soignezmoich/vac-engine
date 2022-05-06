defmodule VacEngineWeb.BlueprintLive.DuplicateButtonComponent do
  @moduledoc """
  Button to duplicate current blueprint.
  """

  use VacEngineWeb, :live_component

  alias VacEngine.Processor

  def handle_event(
        "duplicate",
        _params,
        %{assigns: %{blueprint: blueprint}} = socket
      ) do
    {:ok, new_blueprint} = Processor.duplicate_blueprint(blueprint)

    socket =
      push_redirect(socket,
        to:
          Routes.workspace_blueprint_path(
            socket,
            :summary,
            blueprint.workspace_id,
            new_blueprint.id
          )
      )

    {:noreply, socket}
  end
end
