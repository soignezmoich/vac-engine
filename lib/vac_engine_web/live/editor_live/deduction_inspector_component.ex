defmodule VacEngineWeb.EditorLive.DeductionInspectorComponent do
  use VacEngineWeb, :live_component

  import VacEngine.PipeHelpers
  alias VacEngine.Processor
  alias VacEngine.Processor.Blueprint
  alias VacEngineWeb.EditorLive.DeductionListComponent

  @impl true
  def mount(socket) do
    {:ok, assign(socket, selected_path: nil, on_update: nil)}
  end

  @impl true
  def update(%{action: {:select_path, path}}, socket) do
    {:ok, assign(socket, selected_path: path)}
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
        [_, idx | _] -> %{position: idx + 1}
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
       selected_path: new_path,
       on_update: {:scroll_to, ["deduction.#{deduction.id}"]}
     )}
  end

  @impl true
  def handle_event(
        "delete_deduction",
        _,
        %{assigns: %{blueprint: blueprint, selected_path: selected_path}} =
          socket
      ) do
    can!(socket, :write, blueprint)

    [_, idx | _] = selected_path

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
    {:noreply, assign(socket, selected_path: new_path)}
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

  defp move_deduction(
         %{assigns: %{blueprint: blueprint, selected_path: selected_path}} =
           socket,
         offset
       ) do
    can!(socket, :write, blueprint)

    [_, idx | _] = selected_path
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
    {:noreply, assign(socket, selected_path: new_path)}
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
end
