defmodule VacEngine.Processor.Variable do
  @moduledoc false
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
  import VacEngine.EnumHelpers

  schema "variables" do
    timestamps(type: :utc_datetime)

    belongs_to(:workspace, Workspace)
    belongs_to(:blueprint, Blueprint)

    has_many(:children, Variable,
      on_replace: :delete_if_exists,
      foreign_key: :parent_id
    )

    belongs_to(:parent, Variable)

    has_one(:default, Expression, on_replace: :delete_if_exists)

    field(:type, Ecto.Enum, values: Meta.types())
    field(:mapping, Ecto.Enum, values: Meta.mappings())
    field(:name, :string)
    field(:description, :string)
    field(:enum, ListType)

    field(:path, {:array, :string}, virtual: true)

    field(:new_parent_id, :integer, virtual: true)
    field(:in_list, :boolean, virtual: true)
  end

  @doc false
  def changeset(data, attrs) do
    data
    |> cast(attrs, [
      :new_parent_id,
      :enum,
      :name,
      :type,
      :mapping,
      :description
    ])
    |> validate_enum()
    |> validate_required([:name, :type])
  end

  @doc false
  def create_changeset(data, attrs, ctx) do
    attrs =
      attrs
      |> EctoHelpers.accept_array_or_map_for_embed(:children)

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
    |> validate_enum()
    |> validate_required([:name, :type])
    |> validate_container()
    |> validate_children_state()
    |> validate_parent_type()
    |> check_constraint(:name, name: :variables_name_slug)
    |> unique_constraint(:name, name: :variables_blueprint_id_name_index)
    |> unique_constraint(:name,
      name: :variables_blueprint_id_parent_id_name_index
    )
  end

  @doc false
  def update_changeset(data, attrs, ctx) do
    attrs =
      attrs
      |> EctoHelpers.wrap_in_map(:default, :ast)

    data
    |> cast(attrs, [
      :enum,
      :name,
      :type,
      :mapping,
      :description
    ])
    |> cast_assoc(:default,
      with: {Expression, :nested_changeset, [ctx, []]}
    )
    |> validate_enum()
    |> validate_required([:name, :type])
    |> validate_container()
    |> validate_children_state()
    |> validate_parent_type()
    |> prevent_type_change_when_used()
    |> check_constraint(:name, name: :variables_name_slug)
    |> unique_constraint(:name, name: :variables_blueprint_id_name_index)
    |> unique_constraint(:name,
      name: :variables_blueprint_id_parent_id_name_index
    )
  end

  @doc false
  def update_default_changeset(data, attrs, ctx) do
    attrs =
      attrs
      |> EctoHelpers.wrap_in_map(:default, :ast)

    data
    |> cast(attrs, [])
    |> cast_assoc(:default,
      with: {Expression, :nested_changeset, [ctx, []]}
    )
  end

  @doc false
  def parent_changeset(data, parent_id) do
    data
    |> cast(%{}, [])
    |> put_change(:parent_id, parent_id)
    |> check_constraint(:name, name: :variables_name_slug)
    |> unique_constraint(:name, name: :variables_blueprint_id_name_index)
    |> unique_constraint(:name,
      name: :variables_blueprint_id_parent_id_name_index
    )
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

  @doc """
  Return true if variable is part of the blueprint input
  """
  def input?(nil), do: false

  def input?(var) do
    Meta.input?(var.mapping)
  end

  @doc """
  Return true if variable is part of the blueprint output
  """
  def output?(nil), do: false

  def output?(var) do
    Meta.output?(var.mapping)
  end

  @doc """
  Return true if variable is required
  """
  def required?(nil), do: false

  def required?(var) do
    Meta.required?(var.mapping)
  end

  @doc """
  Return true if variable can have children
  """
  def container?(nil), do: false

  def container?(var) do
    Meta.container_type?(var.type)
  end

  @doc """
  Return true if variable is a list
  """
  def list?(nil), do: false

  def list?(var) do
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
          |> list?()
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
        if container?(parent) do
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

  @doc """
  Return true if variable is used (access DB)
  """
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
      Meta.enum_type?(type) && is_list(enum) && Enum.count(enum) > 0 &&
          Enum.all?(enum, fn v ->
            Meta.of_type?(type, v)
          end) ->
        put_change(changeset, :enum, enum)

      true ->
        put_change(changeset, :enum, nil)
    end
  end

  @doc false
  def insert_bindings(data, ctx) do
    data
    |> update_in([Access.key(:default)], fn e ->
      Expression.insert_bindings(e, ctx)
    end)
  end

  @doc """
  Convert to map for serialization
  """
  def to_map(%Variable{} = v) do
    %{
      type: v.type,
      name: v.name,
      mapping: v.mapping,
      enum: v.enum,
      default: Expression.to_map(v.default),
      children: Enum.map(v.children, &Variable.to_map/1),
      description: v.description
    }
    |> compact
  end
end
