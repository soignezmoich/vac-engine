defmodule VacEngine.Processor.Variable do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias VacEngine.Account.Workspace
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Expression
  alias VacEngine.Processor.BindingElement
  alias VacEngine.Processor.Meta
  alias VacEngine.Processor.Variable
  alias VacEngine.EctoHelpers
  alias VacEngine.Processor.ListType

  schema "variables" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:blueprint, Blueprint)

    has_many(:children, Variable, on_replace: :delete, foreign_key: :parent_id)
    belongs_to(:parent, Variable)

    belongs_to(:default, Expression)

    field(:type, Ecto.Enum, values: Meta.types())
    field(:mapping, Ecto.Enum, values: Meta.mappings())
    field(:name, :string)
    field(:description, :string)
    field(:enum, ListType)

    field(:path, {:array, :string}, virtual: true)
  end

  def create_changeset(data, attrs, ctx) do
    attrs =
      attrs
      |> EctoHelpers.accept_array_or_map_for_embed(:children)
      |> EctoHelpers.wrap_in_map(:default, :ast)

    data
    |> cast(attrs, [
      :enum,
      :name,
      :type,
      :mapping,
      :description
    ])
    |> change(blueprint_id: ctx.blueprint_id, workspace_id: ctx.workspace_id)
    |> cast_assoc(:children, with: {Variable, :create_changeset, [ctx]})
    |> cast_assoc(:default,
      with: {Expression, :changeset, [ctx, [nobindings: true]]}
    )
    |> validate_enum()
    |> validate_required([:name, :type])
    |> validate_container()
    |> validate_children_state()
    |> validate_parent_type()
  end

  def update_changeset(data, attrs, ctx) do
    data
    |> cast(attrs, [
      :enum,
      :name,
      :type,
      :mapping,
      :description
    ])
    |> cast_assoc(:default,
      with: {Expression, :changeset, [ctx, [nobindings: true]]}
    )
    |> validate_enum()
    |> validate_required([:name, :type])
    |> validate_container()
    |> validate_children_state()
    |> validate_parent_type()
    |> prevent_type_change_when_used()
  end

  def parent_changeset(data, parent_id) do
    data
    |> cast(%{}, [])
    |> put_change(:parent_id, parent_id)
    |> prepare_changes(fn changeset ->
      repo = changeset.repo
      id = get_field(changeset, :id)
      blueprint_id = get_field(changeset, :blueprint_id)
      workspace_id = get_field(changeset, :workspace_id)
      parent_path = parent_bindings_path(parent_id, repo)
      new_pos = Enum.count(parent_path)

      from(r in BindingElement,
        where: r.variable_id == ^id
      )
      |> repo.all()
      |> Enum.each(fn be ->
        old_pos = be.position
        diff = new_pos - old_pos

        from(r in BindingElement,
          where: r.binding_id == ^be.binding_id and r.position < ^old_pos
        )
        |> repo.delete_all()
        |> case do
          {^old_pos, _} -> nil
          _ -> raise "cannot shift bindings"
        end

        from(r in BindingElement,
          where: r.binding_id == ^be.binding_id,
          update: [inc: [position: ^diff]]
        )
        |> repo.update_all([])
        |> case do
          {n, _} when is_integer(n) -> nil
          _ -> raise "cannot shift bindings"
        end

        now = DateTime.truncate(DateTime.utc_now(), :second)

        els =
          parent_path
          |> Enum.with_index()
          |> Enum.map(fn {{var_id, idx}, pos} ->
            %{
              inserted_at: now,
              updated_at: now,
              variable_id: var_id,
              blueprint_id: blueprint_id,
              workspace_id: workspace_id,
              position: pos,
              index: idx,
              binding_id: be.binding_id
            }
          end)

        repo.insert_all(BindingElement, els)
        |> case do
          {^new_pos, _} -> nil
          _ -> raise "cannot insert new binding elements"
        end
      end)
      changeset
    end)
  end

  def input?(nil), do: false

  def input?(var) do
    Meta.input?(var.mapping)
  end

  def output?(nil), do: false

  def output?(var) do
    Meta.output?(var.mapping)
  end

  def required?(nil), do: false

  def required?(var) do
    Meta.required?(var.mapping)
  end

  def container_type?(nil), do: false

  def container_type?(var) do
    Meta.container_type?(var.type)
  end

  def list_type?(nil), do: false

  def list_type?(var) do
    Meta.list_type?(var.type)
  end

  defp parent_bindings_path(nil, _), do: []

  defp parent_bindings_path(parent_id, repo) do
    from(r in Variable, where: r.id == ^parent_id)
    |> repo.one()
    |> case do
      nil ->
        []

      v ->
        current =
          v
          |> list_type?()
          |> case do
            true -> {v.id, 0}
            _ -> {v.id, nil}
          end

        parent_bindings_path(v.parent_id, repo) ++ [current]
    end
  end

  defp validate_parent_type(changeset) do
    changeset
    |> prepare_changes(fn changeset ->
      with parent_id when not is_nil(parent_id) <-
             get_field(changeset, :parent_id),
           parent when not is_nil(parent) <-
             changeset.repo.get!(Variable, parent_id) do
        if container_type?(parent) do
          changeset
        else
          add_error(changeset, :parent, "parent type is not container")
        end
      else
        _ -> put_change(changeset, :parent_id, nil)
      end
    end)
  end

  defp prevent_type_change_when_used(changeset) do
    changeset
    |> prepare_changes(fn
      %{changes: %{type: _}} = changeset ->
        id = get_field(changeset, :id)

        used?(id, changeset.repo)
        |> case do
          false ->
            changeset

          _ ->
            add_error(
              changeset,
              :bindings,
              "variable is used and it's type cannot be changed"
            )
        end

      changeset ->
        changeset
    end)
  end

  def used?(id, repo) do
    from(r in BindingElement,
      where: r.variable_id == ^id,
      select: count(r.id)
    )
    |> repo.one()
    |> case do
      0 -> children_used?(id, repo)
      _ -> true
    end
  end

  defp children_used?(id, repo) do
    from(r in Variable,
      where: r.parent_id == ^id,
      select: r.id
    )
    |> repo.all()
    |> Enum.reduce_while(false, fn id, res ->
      used?(id, repo)
      |> case do
        false -> {:cont, res}
        true -> {:halt, true}
      end
    end)
  end

  defp validate_container(changeset) do
    if length(get_field(changeset, :children)) > 0 &&
         !Meta.container_type?(get_field(changeset, :type)) do
      add_error(changeset, :children, "only map and map[] can have children")
    else
      changeset
    end
  end

  defp validate_children_state(changeset) do
    mapping = get_field(changeset, :mapping)

    get_field(changeset, :children)
    |> Enum.any?(fn child ->
      (input?(child) && !Meta.input?(mapping)) ||
        (output?(child) && !Meta.output?(mapping))
    end)
    |> if do
      add_error(
        changeset,
        :children,
        "children cannot be in input or output if parent is not"
      )
    else
      changeset
    end
  end

  defp validate_enum(changeset) do
    type = get_field(changeset, :type)
    enum = get_field(changeset, :enum)

    cond do
      Meta.enum_type?(type) && is_list(enum) &&
          Enum.all?(enum, fn v ->
            Meta.of_type?(type, v)
          end) ->
        put_change(changeset, :enum, enum)

      true ->
        put_change(changeset, :enum, nil)
    end
  end
end
