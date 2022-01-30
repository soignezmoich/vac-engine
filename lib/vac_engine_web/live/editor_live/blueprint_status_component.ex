defmodule VacEngineWeb.EditorLive.BlueprintStatusComponent do
  use VacEngineWeb, :live_component

  alias VacEngine.Processor

  @impl true
  def update(%{blueprint: blueprint}, socket) do
    {:ok,
     assign(socket,
       blueprint: blueprint,
       stats: Processor.blueprint_stats(blueprint),
       issues: Processor.blueprint_issues(blueprint)
     )}
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