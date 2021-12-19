defmodule VacEngineWeb.EditorLive.DeductionHeaderComponent do
  use VacEngineWeb, :live_component
  import VacEngine.PipeHelpers
  import VacEngineWeb.PathHelpers

  @impl true
  def update(
        %{
          cond_columns: cond_columns,
          assign_columns: assign_columns,
          selection: selection
        },
        socket
      ) do
    socket
    |> assign(build_renderable(cond_columns, assign_columns))
    |> assign(selection: selection)
    |> ok()
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
