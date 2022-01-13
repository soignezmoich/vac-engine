defmodule VacEngine.EctoHelpers do
  @moduledoc """
  Set of utilities to help manipulate data in Ecto Schema.
  """
  alias VacEngine.Repo
  import Ecto.Query
  import Ecto.Changeset
  alias Ecto.Changeset
  alias Ecto.Multi

  @doc """
  Used to get data in attributesm will try atom and string keys.
  """
  def get_in_attrs(attrs, path, default \\ nil)

  def get_in_attrs(_attrs, path, _default) when is_binary(path) do
    raise "use atom in path"
  end

  def get_in_attrs(attrs, path, default) when is_atom(path) do
    get_in_attrs(attrs, [path], default)
  end

  def get_in_attrs(attrs, path, default) when is_list(path) do
    apath = Enum.map(path, &Access.key!/1)

    try do
      Kernel.get_in(attrs, apath)
    rescue
      _err ->
        try do
          spath = Enum.map(path, fn s -> Access.key!(to_string(s)) end)
          Kernel.get_in(attrs, spath)
        rescue
          _err ->
            default
        end
    end
  end

  @doc """
  Used to put data in attributesm will try atom and string keys to be compatible
  with existing data.
  """
  def put_in_attrs(_attrs, path, _value) when is_binary(path) do
    raise "use atom in path"
  end

  def put_in_attrs(attrs, path, value) when is_atom(path) do
    put_in_attrs(attrs, [path], value)
  end

  def put_in_attrs(attrs, path, value) when is_list(path) do
    attrs
    |> Enum.at(0)
    |> case do
      {k, _} when is_binary(k) ->
        put_in(attrs, Enum.map(path, &to_string/1), value)

      _ ->
        put_in(attrs, path, value)
    end
  end

  @doc """
  Set position recursively
  """
  def set_positions(attrs, key) do
    skey = to_string(key)

    cond do
      Map.has_key?(attrs, key) ->
        update_in(attrs, [key], fn children ->
          put_position_in_children(children, :position)
        end)

      Map.has_key?(attrs, skey) ->
        update_in(attrs, [skey], fn children ->
          put_position_in_children(children, "position")
        end)

      true ->
        attrs
    end
  end

  @doc """
  Convert `%{foo: %{obja}, bar: %{objb}}` into `[%{name: :foo}, %{name: :bar}]`
  """
  def accept_array_or_map_for_embed(attrs, key) when is_map(attrs) do
    skey = to_string(key)

    cond do
      Map.has_key?(attrs, key) ->
        update_in(attrs, [key], fn children ->
          put_key_in_children(children, :name)
        end)

      Map.has_key?(attrs, skey) ->
        update_in(attrs, [skey], fn children ->
          put_key_in_children(children, "name")
        end)

      true ->
        attrs
    end
  end

  def accept_array_or_map_for_embed(attrs, _key), do: attrs

  @doc """
  Wrap an attribute key into a map with the given root key
  """
  def wrap_in_map(attrs, key, target_name) do
    skey = to_string(key)

    cond do
      Map.has_key?(attrs, key) ->
        update_in(attrs, [key], fn data ->
          %{target_name => data}
        end)

      Map.has_key?(attrs, skey) ->
        target_name = to_string(target_name)

        update_in(attrs, [skey], fn data ->
          %{target_name => data}
        end)

      true ->
        attrs
    end
  end

  defp put_key_in_children(vars, name) when is_map(vars) do
    vars
    |> Enum.map(fn {key, attrs} ->
      Map.put_new(attrs, name, to_string(key))
    end)
  end

  defp put_key_in_children(vars, _name), do: vars

  defp put_position_in_children(children, name) when is_list(children) do
    children
    |> Enum.with_index()
    |> Enum.map(fn {attrs, idx} ->
      Map.put_new(attrs, name, idx)
    end)
  end

  defp put_position_in_children(children, _name), do: children

  @doc """
  Wrapper around `Repo.transaction` that will return an ok or error tuple
  """
  def transaction(multi, key) do
    multi
    |> Repo.transaction()
    |> case do
      {:ok, %{^key => value}} ->
        {:ok, value}

      {:error, _, err, _} ->
        {:error, err}
    end
  end

  @doc """
  Delete all with result wrapping
  """
  def delete_all(q) do
    q
    |> Repo.delete_all()
    |> case do
      {n, _} ->
        {:ok, n}

      _ ->
        :error
    end
  end

  @doc """
  Helper to manage position shifting
  """
  def shift_position(changeset, group_field, group_value) do
    new_pos = get_change(changeset, :position)

    max_query =
      from(r in changeset.data.__struct__,
        where: field(r, ^group_field) == ^group_value,
        select: max(r.position)
      )

    {max_pos, empty?} =
      changeset.repo.one!(max_query)
      |> case do
        nil -> {0, true}
        n -> {n, false}
      end

    cond do
      changeset.action == :update && new_pos ->
        old_pos = changeset.data.position

        cond do
          new_pos > max_pos ->
            add_error(changeset, :position, "is too large, max #{max_pos}")

          new_pos < 0 ->
            add_error(changeset, :position, "is too small, min 0")

          true ->
            dec_query =
              from(r in changeset.data.__struct__,
                where:
                  r.position >= ^old_pos and
                    field(r, ^group_field) == ^group_value
              )

            inc_query =
              from(r in changeset.data.__struct__,
                where:
                  r.position >= ^new_pos and
                    field(r, ^group_field) == ^group_value
              )

            Multi.new()
            |> Multi.update_all(:decrement, dec_query, inc: [position: -1])
            |> Multi.update_all(:increment, inc_query, inc: [position: 1])
            |> changeset.repo.transaction()
            |> case do
              {:ok, _} -> changeset
              _ -> add_error(changeset, :position, "shifting error")
            end
        end

      changeset.action == :insert && empty? ->
        put_change(changeset, :position, 0)

      changeset.action == :insert && !new_pos ->
        put_change(changeset, :position, max_pos + 1)

      changeset.action == :insert && new_pos ->
        cond do
          new_pos > max_pos + 1 ->
            add_error(changeset, :position, "is too large, max #{max_pos + 1}")

          new_pos < 0 ->
            add_error(changeset, :position, "is too small, min 0")

          true ->
            inc_query =
              from(r in changeset.data.__struct__,
                where:
                  r.position >= ^new_pos and
                    field(r, ^group_field) == ^group_value
              )

            Multi.new()
            |> Multi.update_all(:increment, inc_query, inc: [position: 1])
            |> changeset.repo.transaction()
            |> case do
              {:ok, _} -> changeset
              _ -> add_error(changeset, :position, "shifting error")
            end
        end

      true ->
        changeset
    end
  end

  def flatten_changeset_errors(%Changeset{} = ch) do
    Changeset.traverse_errors(ch, fn {msg, _opt} ->
      msg
    end)
    |> flatten_messages()
  end

  defp flatten_messages(map, loc \\ [])

  defp flatten_messages(map, loc) when is_map(map) do
    Enum.reduce(map, [], fn {key, value}, acc ->
      [acc | flatten_messages(value, loc ++ [key])]
    end)
    |> List.flatten()
  end

  defp flatten_messages([item], loc) do
    flatten_messages(item, loc)
  end

  defp flatten_messages(list, loc) when is_list(list) do
    list
    |> Enum.with_index()
    |> Enum.reduce([], fn {value, idx}, acc ->
      [acc | flatten_messages(value, loc ++ [idx])]
    end)
    |> List.flatten()
  end

  defp flatten_messages(str, loc) when is_binary(str) do
    loc = Enum.join(loc, ".")
    ["#{loc}: #{str}"]
  end
end
