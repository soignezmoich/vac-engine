defmodule VacEngineWeb.Editor.DeductionHeaderComponent do
  use Phoenix.Component

  import VacEngineWeb.PathHelpers

  def render(assigns) do
    assigns =
      assign(assigns,
        renderable:
          build_renderable(assigns.cond_columns, assigns.target_columns)
      )

    ~H"""
    <thead>
      <tr>
        <%= if @renderable.has_conds? do %>
          <th colspan={@renderable.cond_count} class="bg-cream-500 text-white px-4">
          </th>
          <th class="bg-white w-5"></th>
        <% end %>
        <th colspan={@renderable.target_count} class="whitespace-nowrap bg-blue-500 text-white py-1 px-4">
          <%= @renderable.target_prefix %> ->
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
        <%= for target_label <- @renderable.target_labels do %>
          <th class="bg-blue-400 text-white py-1 px-4">
            <div class="mx-1">
              <%= target_label %>
            </div>
          </th>
        <% end %>
      </tr>
    </thead>
    """
  end

  def build_renderable(cond_columns, target_columns) do
    cond_labels =
      cond_columns
      |> Enum.map(&Enum.join(&1.variable))

    cond_count = length(cond_labels)

    has_conds? = cond_count > 0

    target_paths =
      target_columns
      |> Enum.map(& &1.variable)

    {target_paths_prefix, truncated_target_paths} = extract_prefix(target_paths)

    target_prefix = target_paths_prefix |> Enum.join(".")

    target_labels =
      truncated_target_paths
      |> Enum.map(&(&1 |> Enum.join(".")))

    target_count = length(target_labels)

    %{
      has_conds?: has_conds?,
      cond_count: cond_count,
      cond_labels: cond_labels,
      target_count: target_count,
      target_prefix: target_prefix,
      target_labels: target_labels
    }
  end
end
