defmodule VacEngineWeb.EditorLive.DeductionInspectorComponent do
  use VacEngineWeb, :live_component

  import VacEngine.PipeHelpers
  alias VacEngine.EnumHelpers
  alias Ecto.Changeset
  alias VacEngine.Processor
  alias VacEngine.Processor.Assignment
  alias VacEngine.Processor.Condition
  alias VacEngine.Processor.Branch
  alias VacEngine.Processor.Column
  alias VacEngineWeb.EditorLive.BlueprintStatusComponent
  alias VacEngineWeb.EditorLive.DeductionListComponent
  alias VacEngineWeb.EditorLive.DeductionCellInspectorComponent
  alias VacEngineWeb.EditorLive.DeductionColumnInspectorComponent
  alias VacEngineWeb.EditorLive.DeductionBranchInspectorComponent
  alias VacEngineWeb.EditorLive.DeductionTableInspectorComponent

  @impl true
  def mount(socket) do
    socket
    |> assign(
      blueprint: nil,
      on_update: nil,
      changeset: nil,
      inspector: nil,
      tab: :cell
    )
    |> select(nil)
    |> ok()
  end

  @impl true
  def update(%{action: {:select, selection}}, socket) do
    {:ok, select(socket, selection)}
  end

  @impl true
  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> select()
    |> on_update()
    |> ok()
  end

  @impl true
  def handle_event(
        "new_deduction",
        _,
        %{assigns: %{blueprint: blueprint}} = socket
      ) do
    can!(socket, :write, blueprint)
    changeset = Changeset.cast({%{}, %{variable: :string}}, %{}, [])

    vars =
      blueprint.variable_path_index
      |> Enum.map(fn {path, _var} ->
        path = Enum.join(path, ".")
        {path, path}
      end)
      |> Enum.sort()

    socket
    |> assign(changeset: changeset, inspector: :new_deduction, variables: vars)
    |> pair(:noreply)
  end

  @impl true
  def handle_event(
        "add_deduction",
        %{"deduction" => %{"variable" => variable_path}},
        %{assigns: %{blueprint: blueprint, selection: selection}} = socket
      ) do
    can!(socket, :write, blueprint)

    attrs =
      case selection do
        %{deduction: %{position: idx}} -> %{position: idx + 1}
        _ -> %{}
      end
      |> Map.merge(%{
        branches: [%{}],
        columns: [
          %{
            type: :assignment,
            variable: variable_path |> String.split(".")
          }
        ]
      })

    {:ok, deduction} = Processor.create_deduction(blueprint, attrs)

    selection = %{deduction: deduction}

    send(self(), :reload_blueprint)

    socket
    |> assign(
      selection: selection,
      on_update: {:scroll_to, ["deduction.#{deduction.id}"]}
    )
    |> pair(:noreply)
  end

  @impl true
  def handle_event(
        "delete_deduction",
        _,
        %{assigns: %{blueprint: blueprint, selection: selection}} = socket
      ) do
    can!(socket, :write, blueprint)

    %{deduction: deduction} = selection

    {:ok, _deduction} = Processor.delete_deduction(deduction)

    idx =
      if deduction.position == 0 do
        1
      else
        deduction.position - 1
      end

    selection =
      if blueprint.deductions |> Enum.count() > 1 do
        %{deduction: blueprint.deductions |> Enum.at(idx)}
      else
        nil
      end

    send(self(), :reload_blueprint)
    {:noreply, assign(socket, selection: selection)}
  end

  @impl true
  def handle_event(
        "move_deduction_up",
        _,
        socket
      ) do
    move_deduction(socket, -1)
  end

  @impl true
  def handle_event(
        "move_deduction_down",
        _,
        socket
      ) do
    move_deduction(socket, 1)
  end

  @impl true
  def handle_event(
        "add_branch",
        _,
        %{assigns: %{blueprint: blueprint, selection: selection}} = socket
      ) do
    can!(socket, :write, blueprint)

    {deduction, attrs} =
      case selection do
        %{deduction: deduction, branch: %{position: idx}} ->
          {deduction, %{position: idx + 1}}

        %{deduction: deduction} ->
          {deduction, %{}}
      end

    {:ok, branch} = Processor.create_branch(deduction, attrs)

    selection =
      if Map.get(selection, :column) do
        Map.put(selection, :branch, branch)
      else
        %{deduction: deduction}
      end

    send(self(), :reload_blueprint)

    {:noreply, assign(socket, selection: selection)}
  end

  @impl true
  def handle_event(
        "delete_branch",
        _,
        %{assigns: %{blueprint: blueprint, selection: selection}} = socket
      ) do
    can!(socket, :write, blueprint)

    %{deduction: deduction, branch: branch} = selection

    if deduction.branches |> Enum.count() < 2 do
      raise "cannot delete last branch"
    end

    {:ok, _branch} = Processor.delete_branch(branch)

    idx =
      if branch.position == 0 do
        1
      else
        branch.position - 1
      end

    selection = Map.put(selection, :branch, deduction.branches |> Enum.at(idx))

    send(self(), :reload_blueprint)

    {:noreply, assign(socket, selection: selection)}
  end

  @impl true
  def handle_event(
        "move_branch_up",
        _,
        socket
      ) do
    move_branch(socket, -1)
  end

  @impl true
  def handle_event(
        "move_branch_down",
        _,
        socket
      ) do
    move_branch(socket, 1)
  end

  @impl true
  def handle_event(
        "new_column",
        _,
        %{assigns: %{blueprint: blueprint}} = socket
      ) do
    can!(socket, :write, blueprint)

    changeset =
      Changeset.cast({%{}, %{variable: :string, type: :string}}, %{}, [])

    vars =
      blueprint.variable_path_index
      |> Enum.map(fn {path, _var} ->
        path = Enum.join(path, ".")
        {path, path}
      end)
      |> Enum.sort()

    socket
    |> assign(changeset: changeset, inspector: :new_column, variables: vars)
    |> pair(:noreply)
  end

  @impl true
  def handle_event(
        "add_column",
        %{"column" => %{"variable" => variable_path, "type" => type}},
        %{assigns: %{blueprint: blueprint, selection: selection}} = socket
      ) do
    can!(socket, :write, blueprint)

    {deduction, position} =
      case selection do
        %{deduction: deduction, column: %{position: idx}} ->
          {deduction, idx + 1}

        %{deduction: deduction} ->
          {deduction, 0}
      end

    attrs = %{
      position: position,
      variable: variable_path |> String.split("."),
      type: type
    }

    {:ok, column} = Processor.create_column(blueprint, deduction, attrs)

    selection =
      if Map.get(selection, :branch) do
        Map.put(selection, :column, column)
      else
        %{deduction: deduction}
      end

    send(self(), :reload_blueprint)

    {:noreply, assign(socket, selection: selection)}
  end

  @impl true
  def handle_event(
        "delete_column",
        _,
        %{assigns: %{blueprint: blueprint, selection: selection}} = socket
      ) do
    can!(socket, :write, blueprint)

    %{deduction: deduction, column: column} = selection

    assignment_count =
      deduction.columns
      |> Enum.filter(&(&1.type == :assignment))
      |> Enum.count()

    can_delete =
      if column.type == :assignment do
        assignment_count > 1
      else
        true
      end

    if !can_delete do
      raise "cannot delete last assignment column"
    end

    {:ok, _column} = Processor.delete_column(column)

    idx =
      if column.position == 0 do
        1
      else
        column.position - 1
      end

    selection = Map.put(selection, :column, deduction.columns |> Enum.at(idx))

    send(self(), :reload_blueprint)

    {:noreply, assign(socket, selection: selection)}
  end

  @impl true
  def handle_event(
        "move_column_left",
        _,
        socket
      ) do
    move_column(socket, -1)
  end

  @impl true
  def handle_event(
        "move_column_right",
        _,
        socket
      ) do
    move_column(socket, 1)
  end

  @impl true
  def handle_event(
        "cancel",
        _,
        %{assigns: %{selection: selection}} = socket
      ) do
    {:noreply, socket |> select(selection)}
  end

  @impl true
  def handle_event(
        "change_tab",
        %{"tab" => tab},
        socket
      ) do
    {:noreply, assign(socket, tab: String.to_existing_atom(tab))}
  end

  defp move_deduction(
         %{assigns: %{blueprint: blueprint, selection: selection}} = socket,
         offset
       ) do
    can!(socket, :write, blueprint)

    %{deduction: deduction} = selection
    new_pos = deduction.position + offset

    {:ok, deduction} =
      Processor.update_deduction(deduction, %{position: new_pos})

    selection = %{selection | deduction: deduction}

    send(self(), :reload_blueprint)
    {:noreply, assign(socket, selection: selection)}
  end

  defp move_branch(
         %{assigns: %{blueprint: blueprint, selection: selection}} = socket,
         offset
       ) do
    can!(socket, :write, blueprint)

    %{branch: %{position: idx} = branch} = selection
    new_pos = idx + offset

    {:ok, branch} = Processor.update_branch(branch, %{position: new_pos})

    selection = %{selection | branch: branch}

    send(self(), :reload_blueprint)
    {:noreply, assign(socket, selection: selection)}
  end

  defp move_column(
         %{assigns: %{blueprint: blueprint, selection: selection}} = socket,
         offset
       ) do
    can!(socket, :write, blueprint)

    %{column: %{position: idx} = column} = selection
    new_pos = idx + offset

    {:ok, column} = Processor.update_column(column, %{position: new_pos})

    selection = %{selection | column: column}

    send(self(), :reload_blueprint)
    {:noreply, assign(socket, selection: selection)}
  end

  defp on_update(%{assigns: %{on_update: {f, args}}} = socket)
       when is_atom(f) and not is_nil(f) do
    apply(__MODULE__, f, [socket | args])
    |> assign(on_update: nil)
  end

  defp on_update(socket), do: socket

  def scroll_to(socket, target) do
    push_event(socket, "action", %{
      id: :deduction_list_wrapper,
      action: :scroll_to,
      params: [target]
    })
  end

  def select(socket, selection \\ :reselect) do
    blueprint = socket.assigns.blueprint

    {selection, reselect} =
      if selection == :reselect do
        {socket.assigns.selection, true}
      else
        {selection, false}
      end

    {
      deduction,
      column,
      branch,
      _cell
    } =
      if is_map(selection) and not is_nil(blueprint) do
        {
          Map.get(selection, :deduction),
          Map.get(selection, :column),
          Map.get(selection, :branch),
          Map.get(selection, :cell)
        }
      else
        {nil, nil, nil, nil}
      end

    deduction =
      if deduction do
        blueprint.deductions |> EnumHelpers.find_by(:id, deduction.id)
      else
        nil
      end

    branch =
      if not is_nil(deduction) and not is_nil(branch) do
        deduction.branches |> EnumHelpers.find_by(:id, branch.id)
      else
        nil
      end

    column =
      if not is_nil(deduction) and not is_nil(column) do
        deduction.columns |> EnumHelpers.find_by(:id, column.id)
      else
        nil
      end

    cell =
      if not is_nil(branch) and not is_nil(column) do
        EnumHelpers.find_by(branch.assignments, :column_id, column.id) ||
          EnumHelpers.find_by(branch.conditions, :column_id, column.id)
      else
        nil
      end

    selection = %{
      deduction: deduction,
      branch: branch,
      column: column,
      cell: cell
    }

    deduction_idx =
      case deduction do
        nil -> nil
        d -> d.position
      end

    branch_idx =
      case branch do
        nil ->
          nil

        b ->
          b.position
      end

    deduction_count =
      case blueprint do
        nil -> 0
        br -> br.deductions |> Enum.count()
      end

    {branch_count, column_count, assignment_count, split_position} =
      case deduction do
        nil ->
          {0, 0, 0, 0}

        d ->
          assignments = d.columns |> Enum.filter(&(&1.type == :assignment))

          {Enum.count(d.branches), Enum.count(d.columns),
           assignments |> Enum.count(), Enum.at(assignments, 0).position}
      end

    if reselect do
      send_update(DeductionListComponent,
        id: "deduction_list",
        action: {:select, selection}
      )
    end

    {can_delete_column, can_move_left_column, can_move_right_column} =
      case column do
        %{type: :assignment, position: pos} ->
          {assignment_count > 1, pos > split_position, pos < column_count - 1}

        %{type: :condition, position: pos} ->
          {true, pos > 0, pos < split_position - 1}

        _ ->
          {false, false, false}
      end

    inspector =
      case selection do
        %{branch: %Branch{id: _}, column: %Column{id: _}} -> :edit_cell
        _ -> :none
      end

    cell =
      case selection do
        %{cell: %Condition{} = c} -> c
        %{cell: %Assignment{} = a} -> a
        _ -> nil
      end

    assign(socket,
      cell: cell,
      deduction: deduction,
      column: column,
      branch: branch,
      inspector: inspector,
      selection: selection,
      can_add_deduction?: true,
      can_move_up_deduction?: deduction_idx && deduction_idx > 0,
      can_move_down_deduction?: deduction_idx < deduction_count - 1,
      can_delete_deduction?: deduction_idx != nil,
      can_add_branch?: deduction_idx != nil,
      can_move_up_branch?: branch_idx && branch_idx > 0,
      can_move_down_branch?: branch_idx < branch_count - 1,
      can_delete_branch?: branch_idx != nil && branch_count > 1,
      can_add_column?: deduction_idx != nil,
      can_move_left_column?: can_move_left_column,
      can_move_right_column?: can_move_right_column,
      can_delete_column?: can_delete_column
    )
  end
end
