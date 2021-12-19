defmodule VacEngineWeb.EditorLive.DeductionComponent do
  use VacEngineWeb, :live_component
  import VacEngine.PipeHelpers
  alias VacEngineWeb.EditorLive.DeductionHeaderComponent
  alias VacEngineWeb.EditorLive.DeductionBranchComponent

  @impl true
  def update(
        %{deduction: deduction, selection: selection},
        socket
      ) do
    socket
    |> assign(build_renderable(deduction, selection))
    |> assign(deduction: deduction, selection: selection)
    |> ok()
  end

  def build_renderable(deduction, selection) do
    %{branches: branches, columns: columns} = deduction

    cond_columns =
      columns
      |> Enum.filter(&(&1.type == :condition))

    assign_columns =
      columns
      |> Enum.filter(&(&1.type == :assignment))

    selected =
      case selection do
        %{deduction: %{id: did}} ->
          deduction.id == did

        _ ->
          false
      end

    %{
      selected?: selected,
      branches: branches,
      cond_columns: cond_columns,
      assign_columns: assign_columns
    }
  end
end
