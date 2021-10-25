defmodule VacEngineWeb.BlueprintsListComponent do
  use VacEngineWeb, :component

  def blueprints_list(assigns) do
    ~H"""
    <div>
      <%= case @blueprints do %>
      <% [] -> %>
        <p class="font-medium text-lg">No blueprint in workspace</p>
      <% brs -> %>
        <table class="listing-table">
          <thead>
            <th>Name</th>
            <th></th>
          </thead>
          <tbody>
            <%= for b <- brs do %>
              <tr>
                <td>
                  <%= b.name %>
                </td>
                <td>
                  <%= live_redirect("Open",
                        to: Routes.workspace_blueprint_path(Endpoint, :summary, b.workspace_id, b.id),
                        class: "btn-sm inline-block"
                      ) %>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      <% end %>
    </div>
    """
  end
end
