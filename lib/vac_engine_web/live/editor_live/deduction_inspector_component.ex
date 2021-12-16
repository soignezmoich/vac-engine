defmodule VacEngineWeb.EditorLive.DeductionInspectorComponent do
  use VacEngineWeb, :live_component

  import VacEngine.PipeHelpers
  alias VacEngine.Processor
  alias VacEngine.Processor.Blueprint
  alias VacEngineWeb.EditorLive.DeductionListComponent

  @impl true
  def mount(socket) do
    socket
    |> assign(blueprint: nil, on_update: nil, changeset: nil)
    |> select(nil)
    |> ok()
  end

  @impl true
  def update(%{action: {:select_path, path}}, socket) do
    {:ok, select(socket, path)}
  end

  @impl true
  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> on_update()
    |> ok()
  end

  @impl true
  def handle_event(
        "add_deduction",
        _,
        %{assigns: %{blueprint: blueprint, selected_path: selected_path}} =
          socket
      ) do
    can!(socket, :write, blueprint)

    attrs =
      case selected_path do
        [:deductions, idx | _] -> %{position: idx + 1}
        _ -> %{}
      end

    {:ok, deduction} = Processor.create_deduction(blueprint, attrs)

    new_path = [:deductions, deduction.position]

    send_update(DeductionListComponent,
      id: "deduction_list",
      action: {:select_path, new_path}
    )

    send(self(), :reload_blueprint)

    {:noreply,
     assign(socket,
       on_update: {:scroll_to, ["deduction.#{deduction.id}"]}
     )
     |> select(new_path)}
  end

  @impl true
  def handle_event(
        "delete_deduction",
        _,
        %{assigns: %{blueprint: blueprint, selected_path: selected_path}} =
          socket
      ) do
    can!(socket, :write, blueprint)

    [:deductions, idx | _] = selected_path

    deduction = blueprint.deductions |> Enum.at(idx)

    {:ok, _deduction} = Processor.delete_deduction(deduction)

    new_path =
      if idx > 0 do
        [:deductions, idx - 1]
      else
        nil
      end

    send_update(DeductionListComponent,
      id: "deduction_list",
      action: {:select_path, new_path}
    )

    send(self(), :reload_blueprint)
    {:noreply, select(socket, new_path)}
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
        %{assigns: %{blueprint: blueprint, selected_path: selected_path}} =
          socket
      ) do
    can!(socket, :write, blueprint)

    {deduction_idx, attrs} =
      case selected_path do
        [:deductions, deduction_idx, :branches, idx | _] -> {deduction_idx, %{position: idx + 1}}
        [:deductions, deduction_idx | _] -> {deduction_idx, %{}}
      end

    deduction = blueprint.deductions |> Enum.at(deduction_idx)
    {:ok, branch} = Processor.create_branch(deduction, attrs)

    new_path = [:deductions, deduction_idx, :branches, branch.position]

    send_update(DeductionListComponent,
      id: "deduction_list",
      action: {:select_path, new_path}
    )

    send(self(), :reload_blueprint)

    {:noreply,
     socket
     |> select(new_path)}
  end

  @impl true
  def handle_event(
        "delete_branch",
        _,
        %{assigns: %{blueprint: blueprint, selected_path: selected_path}} =
          socket
      ) do
    can!(socket, :write, blueprint)

    [:deductions, deduction_idx, :branches, idx | _] = selected_path

    deduction = blueprint.deductions |> Enum.at(deduction_idx)
    branch = deduction.branches |> Enum.at(idx)

    {:ok, _branch} = Processor.delete_branch(branch)

    new_path =
      cond do
        idx > 0 ->
          [:deductions, deduction_idx, :branches, idx - 1]

        deduction.branches |> Enum.count() > 1 ->
          [:deductions, deduction_idx, :branches, 0]

        true ->
          [:deductions, deduction_idx]
      end

    send_update(DeductionListComponent,
      id: "deduction_list",
      action: {:select_path, new_path}
    )

    send(self(), :reload_blueprint)

    {:noreply,
     socket
     |> select(new_path)}
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

  defp move_deduction(
         %{assigns: %{blueprint: blueprint, selected_path: selected_path}} =
           socket,
         offset
       ) do
    can!(socket, :write, blueprint)

    [:deductions, idx | _] = selected_path
    new_pos = idx + offset

    deduction = blueprint.deductions |> Enum.at(idx)

    {:ok, _deduction} =
      Processor.update_deduction(deduction, %{position: new_pos})

    new_path = [:deductions, new_pos]

    send_update(DeductionListComponent,
      id: "deduction_list",
      action: {:select_path, new_path}
    )

    send(self(), :reload_blueprint)
    {:noreply, select(socket, new_path)}
  end

  defp move_branch(
         %{assigns: %{blueprint: blueprint, selected_path: selected_path}} =
           socket,
         offset
       ) do
    can!(socket, :write, blueprint)

    [:deductions, deduction_idx, :branches, idx | _] = selected_path
    new_pos = idx + offset

    deduction = blueprint.deductions |> Enum.at(deduction_idx)
    branch = deduction.branches |> Enum.at(idx)

    {:ok, _deduction} = Processor.update_branch(branch, %{position: new_pos})

    new_path = [:deductions, deduction_idx, :branches, new_pos]

    send_update(DeductionListComponent,
      id: "deduction_list",
      action: {:select_path, new_path}
    )

    send(self(), :reload_blueprint)
    {:noreply, select(socket, new_path)}
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

  defp select(socket, path) do
    blueprint = socket.assigns.blueprint

    {idx, branch_idx} =
      case path do
        [_, idx, _, branch_idx | _] -> {idx, branch_idx}
        [_, idx | _] -> {idx, nil}
        _ -> {nil, nil}
      end

    count =
      case blueprint do
        nil -> 0
        br -> br.deductions |> Enum.count()
      end

    branch_count =
      case idx do
        nil ->
          0

        n ->
          blueprint.deductions
          |> Enum.at(n)
          |> case do
            nil ->
              0

            d ->
              Enum.count(d.branches)
          end
      end

    assign(socket,
      selected_path: path,
      can_add_deduction?: true,
      can_move_up_deduction?: idx && idx > 0,
      can_move_down_deduction?: idx < count - 1,
      can_delete_deduction?: idx != nil,
      can_add_branch?: idx != nil,
      can_move_up_branch?: branch_idx && branch_idx > 0,
      can_move_down_branch?: branch_idx < branch_count - 1,
      can_delete_branch?: branch_idx != nil
    )
  end
end
