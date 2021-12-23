defmodule VacEngineWeb.EditorLive.VariableInspectorComponent do
  use VacEngineWeb, :live_component

  alias Ecto.Changeset
  alias VacEngine.Processor
  alias VacEngine.Processor.Meta
  alias VacEngine.Processor.Variable
  import VacEngine.VariableHelpers
  import VacEngine.PipeHelpers
  alias VacEngine.Repo
  alias Ecto.Multi
  alias VacEngineWeb.EditorLive.VariableListComponent

  import VacEngineWeb.BlueprintLive.Edit, only: [get_blueprint!: 2]

  @types ~w( boolean integer number string date datetime map)a

  @impl true
  def mount(socket) do
    {:ok,
     assign(socket,
       types: @types,
       variable: nil,
       can_write: false,
       blueprint: nil,
       containers: [],
       changeset: nil,
       enum_new: nil,
       used?: false
     )}
  end

  @impl true
  def update(%{action: {:select_variable, var}}, socket) do
    socket
    |> assign(variable: var)
    |> set_variable
    |> ok()
  end

  @impl true
  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> set_variable()
    |> ok()
  end

  @impl true
  def handle_event(
        "add_enum",
        _,
        %{assigns: %{enum_new: new, changeset: changeset}} = socket
      ) do
    values = Changeset.get_field(changeset, :enum)

    case new do
      nil ->
        {:noreply, socket}

      val ->
        values = Enum.uniq((values || []) ++ [val])

        socket
        |> assign(enum_new: nil)
        |> update_changeset(%{enum: values})
        |> pair(:noreply)
    end
  end

  @impl true
  def handle_event(
        "remove_enum",
        %{"idx" => idx},
        %{assigns: %{changeset: changeset}} = socket
      ) do
    changeset
    |> Changeset.get_field(:enum)
    |> List.delete_at(String.to_integer(idx))
    |> then(fn values -> update_changeset(socket, %{enum: values}) end)
    |> pair(:noreply)
  end

  @impl true
  def handle_event(
        "validate",
        %{"_target" => ["enum", "new"], "enum" => %{"new" => val}},
        socket
      ) do
    {:noreply, assign(socket, enum_new: val)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"variable" => params},
        socket
      ) do
    socket
    |> update_changeset(params)
    |> pair(:noreply)
  end

  @impl true
  def handle_event(
        "save",
        _,
        %{
          assigns: %{
            blueprint: blueprint,
            changeset: changeset,
            variable: %Variable{id: nil}
          }
        } = socket
      ) do
    attrs = changeset.changes

    case Changeset.get_field(changeset, :parent_id) do
      nil ->
        Processor.create_variable(blueprint, attrs)

      id ->
        Processor.create_variable(
          Map.get(blueprint.variable_id_index, id),
          attrs
        )
    end
    |> case do
      {:ok, var} ->
        socket
        |> update_notify_var(var)
        |> pair(:noreply)

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_event(
        "save",
        _,
        %{
          assigns: %{
            blueprint: blueprint,
            changeset: changeset,
            variable: variable
          }
        } = socket
      ) do
    can!(socket, :write, blueprint)
    attrs = changeset.changes

    # TODO move to Processor.Variables
    Multi.new()
    |> Multi.run(:update, fn _repo, _ ->
      Processor.update_variable(variable, attrs)
    end)
    |> Multi.run(:move, fn _repo, %{update: variable} ->
      case Changeset.fetch_change(changeset, :parent_id) do
        :error ->
          {:ok, variable}

        {:ok, nil} ->
          Processor.move_variable(variable, blueprint)

        {:ok, id} ->
          Processor.move_variable(
            variable,
            blueprint.variable_id_index |> Map.get(id)
          )
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{move: var, update: _var}} ->
        socket
        |> update_notify_var(var)
        |> pair(:noreply)

      {:error, _, changeset, _} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_event(
        "cancel",
        _,
        %{assigns: %{variable: %Variable{id: nil}}} = socket
      ) do
    socket
    |> assign(variable: nil)
    |> set_variable()
    |> pair(:noreply)
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket
    |> set_variable()
    |> pair(:noreply)
  end

  @impl true
  def handle_event(
        "delete",
        _,
        %{assigns: %{blueprint: blueprint, variable: variable}} = socket
      ) do
    can!(socket, :write, blueprint)

    Processor.delete_variable(variable)
    |> case do
      {:ok, _var} ->
        socket
        |> update_notify_var(nil)
        |> pair(:noreply)

      _error ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event(
        "add_input",
        _,
        socket
      ) do
    var = %Variable{mapping: :in_required, type: :string}

    socket
    |> assign(variable: var)
    |> set_variable()
    |> update_changeset()
    |> force_changes([:mapping, :type])
    |> pair(:noreply)
  end

  @impl true
  def handle_event(
        "add_intermediate",
        _,
        socket
      ) do
    var = %Variable{mapping: :none, type: :string}

    socket
    |> assign(variable: var)
    |> set_variable()
    |> update_changeset()
    |> force_changes([:mapping, :type])
    |> pair(:noreply)
  end

  @impl true
  def handle_event(
        "add_output",
        _,
        socket
      ) do
    var = %Variable{mapping: :out, type: :string}

    socket
    |> assign(variable: var)
    |> set_variable()
    |> update_changeset()
    |> force_changes([:mapping, :type])
    |> pair(:noreply)
  end

  defp force_changes(%{assigns: %{changeset: changeset}} = socket, fields) do
    fields
    |> Enum.reduce(changeset, fn field, changeset ->
      Changeset.force_change(
        changeset,
        field,
        Changeset.get_field(changeset, field)
      )
    end)
    |> then(fn ch -> assign(socket, changeset: ch) end)
  end

  defp set_variable(
         %{
           assigns: %{
             variable: v,
             blueprint: b
           }
         } = socket
       )
       when is_nil(v) or is_nil(b) do
    assign(socket,
      variable: nil,
      can_write: false,
      changeset: nil,
      containers: [],
      used?: false
    )
  end

  defp set_variable(
         %{
           assigns: %{
             variable: variable,
             blueprint: blueprint
           }
         } = socket
       ) do
    send_update(VariableListComponent,
      id: "variable_list",
      action: {:select_variable, variable}
    )

    changeset =
      Processor.change_variable(
        variable,
        %{}
      )

    assign(socket,
      can_write: can?(socket, :write, blueprint),
      changeset: changeset,
      containers: containers(variable, blueprint.variables),
      used?: Processor.variable_used?(variable)
    )
  end

  defp update_notify_var(%{assigns: %{blueprint: blueprint}} = socket, var) do
    blueprint = get_blueprint!(blueprint.id, socket)
    send(self(), {:update_blueprint, blueprint})

    var =
      case var do
        nil ->
          nil

        var ->
          blueprint.variable_id_index |> Map.get(var.id)
      end

    socket
    |> assign(variable: var)
    |> set_variable
  end

  defp update_changeset(
         %{
           assigns: %{
             changeset: changeset
           }
         } = socket,
         attrs \\ %{}
       ) do
    changeset =
      %{changeset | errors: [], valid?: true}
      |> Processor.change_variable(attrs)

    assign(socket, changeset: changeset)
  end

  defp containers(var, vars) do
    case {Variable.input?(var), Variable.output?(var)} do
      {true, _} -> get_containers(vars, "input")
      {false, false} -> get_containers(vars, "intermediate")
      {_, true} -> get_containers(vars, "output")
    end
    |> Enum.map(fn c ->
      {c.path |> Enum.join("."), c.id}
    end)
  end
end
