defmodule VacEngine.Utils do
  def accept_array_or_map_for_embed(attrs, key) when is_map(attrs) do
    skey = to_string(key)

    cond do
      Map.has_key?(attrs, key) ->
        update_in(attrs, [key], &put_key_in_child/1)

      Map.has_key?(attrs, skey) ->
        update_in(attrs, [skey], &put_key_in_child/1)

      true ->
        attrs
    end
  end

  def accept_array_or_map_for_embed(attrs, _key), do: attrs

  defp put_key_in_child(vars) when is_map(vars) do
    vars
    |> Enum.map(fn {key, attrs} ->
      if is_atom(key) do
        Map.put(attrs, :name, key)
      else
        Map.put(attrs, "name", key)
      end
    end)
  end

  defp put_key_in_child(vars), do: vars
end
