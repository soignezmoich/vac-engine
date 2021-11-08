defmodule VacEngineWeb.Editor.DeductionHeaderComponent do
  use Phoenix.Component

  import VacEngineWeb.PathHelpers

  def render(assigns) do
    assigns =
      assign(assigns,
        renderable:
          build_renderable(assigns.cond_columns, assigns.assign_columns)
      )

    ~H"""
    <thead>
      <tr>
        <%= if @renderable.has_conds? do %>
          <th colspan={@renderable.cond_count} class="bg-cream-500 text-white px-4">
          </th>
          <th class="bg-white w-5"></th>
        <% end %>
        <th colspan={@renderable.assign_count} class="whitespace-nowrap bg-blue-500 text-white py-1 px-4">
          <%= @renderable.assign_prefix %> ->
        </th>
      </tr>
      <tr>
        <%= if @renderable.has_conds? do %>
          <%= for cond_label <- @renderable.cond_labels do %>
            <th class="bg-cream-400 text-white py-1 px-4">
              <div class="mx-1">
                <%= cond_label %>
              </div>
            </th>
          <% end %>
          <th class="bg-white"></th>
        <% end %>
        <%= for assign_label <- @renderable.assign_labels do %>
          <th class="bg-blue-400 text-white py-1 px-4">
            <div class="mx-1">
              <%= assign_label %>
            </div>
          </th>
        <% end %>
      </tr>
    </thead>
    """
  end

  def build_renderable(cond_columns, assign_columns) do
    cond_labels =
      cond_columns
      |> Enum.map(& &1.variable)
      |> Enum.map(&(&1 |> Enum.join(".")))

    cond_count = length(cond_labels)

    has_conds? = cond_count > 0

    assign_paths =
      assign_columns
      |> Enum.map(& &1.variable)

    {assign_paths_prefix, truncated_assign_paths} = extract_prefix(assign_paths)

    assign_prefix = assign_paths_prefix |> Enum.join(".")

    assign_labels =
      truncated_assign_paths
      |> Enum.map(&(&1 |> Enum.join(".")))

    assign_count = length(assign_labels)

    %{
      has_conds?: has_conds?,
      cond_count: cond_count,
      cond_labels: cond_labels,
      assign_count: assign_count,
      assign_prefix: assign_prefix,
      assign_labels: assign_labels
    }
  end
end
