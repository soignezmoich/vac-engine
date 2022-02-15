defmodule VacEngineWeb.EditorLive.BlueprintStatusComponent do
  use VacEngineWeb, :live_component

  import VacEngine.PipeHelpers

  alias VacEngine.Processor

  @impl true
  def update(%{blueprint: blueprint}, socket) do
    socket
    |> assign(
      blueprint: blueprint,
      stats: Processor.blueprint_stats(blueprint),
      issues: Processor.blueprint_issues(blueprint)
    )
    |> ok()
  end

  @impl true
  def handle_event(
        "fix",
        _,
        %{
          assigns: %{
            blueprint: blueprint
          }
        } = socket
      ) do
    {:ok, _br} = Processor.autofix_blueprint(blueprint)

    send(self(), :reload_blueprint)

    {:noreply, socket}
  end
end
