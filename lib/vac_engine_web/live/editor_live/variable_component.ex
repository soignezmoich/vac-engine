defmodule VacEngineWeb.EditorLive.VariableComponent do
  use VacEngineWeb, :live_component

  alias VacEngineWeb.EditorLive.VariableInspectorComponent
  alias VacEngineWeb.EditorLive.VariableListComponent

  @impl true
  def update(
        %{variable: variable, selected: selected, even: even},
        socket
      ) do
    {
      :ok,
      socket
      |> assign(build_renderable(variable, even, selected))
      |> assign(variable: variable)
    }
  end

  @impl true
  def handle_event("select", _, socket) do
    send_update(VariableListComponent,
      id: "variable_list",
      action: {:select_variable, socket.assigns.variable}
    )

    send_update(VariableInspectorComponent,
      id: "variable_inspector",
      action: {:select_variable, socket.assigns.variable}
    )

    {:noreply, socket}
  end

  def build_renderable(variable, even, is_selected) do
    indentation =
      variable.path
      # remove variable name
      |> Enum.drop(-2)
      # turn the variable parents into indentation
      |> Enum.map(fn _ -> "   " end)
      |> then(fn i ->
        if Enum.count(variable.path) > 1 do
          i ++ ["└─"]
        else
          i
        end
      end)
      |> Enum.join()

    required =
      case variable.mapping do
        :in_required -> "*"
        _ -> ""
      end

    enum =
      case variable do
        %{enum: nil} -> []
        %{enum: enum} -> enum
        _ -> []
      end
      |> Enum.join(", ")

    dot_path = variable.path |> Enum.join(".")

    selected = "bg-pink-600 text-white"

    unselected_color =
      if variable.mapping == "output" do
        "bg-blue-200"
      else
        "bg-cream-200"
      end

    unselected_opacity =
      if even do
        "bg-opacity-30"
      else
        "bg-opacity-50"
      end

    unselected = "#{unselected_color} #{unselected_opacity}"

    row_class =
      if is_selected do
        selected
      else
        unselected
      end

    row_class =
      "p-1 grid grid-cols-[300px_150px_200px_minmax(150px,_1fr)] #{row_class}"

    %{
      description: variable.description,
      name: variable.name,
      type: variable.type,
      indentation: indentation,
      required: required,
      enum: enum,
      row_class: row_class,
      dot_path: dot_path
    }
  end
end
