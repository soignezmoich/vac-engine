defmodule VacEngine.EctoHelpers do
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
end
