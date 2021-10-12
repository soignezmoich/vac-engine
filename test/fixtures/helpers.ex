defmodule Fixtures.Helpers do
  def age(str) do
    Timex.diff(NaiveDateTime.utc_now(), Timex.parse!(str, "{ISOdate}"), :years)
  end

  def now() do
    Timex.format!(NaiveDateTime.utc_now(), "{ISOdate}")
  end

  def smap(map) do
    map
    |> stringify_keys()
  end

  defp stringify_keys(map) when is_map(map) do
    map
    |> Enum.map(fn {key, val} ->
      key =
        if is_atom(key) do
          to_string(key)
        else
          key
        end

      val = stringify_keys(val)

      {key, val}
    end)
    |> Map.new()
  end

  defp stringify_keys(list) when is_list(list) do
    list
    |> Enum.map(&stringify_keys/1)
  end

  defp stringify_keys(v) when is_boolean(v), do: v
  defp stringify_keys(v) when is_atom(v), do: to_string(v)
  defp stringify_keys(v), do: v

  def amap(map) do
    map
    |> atomify_keys()
  end

  defp atomify_keys(map) when is_map(map) do
    map
    |> Enum.map(fn {key, val} ->
      key =
        if is_binary(key) do
          String.to_atom(key)
        else
          key
        end

      val = atomify_keys(val)

      {key, val}
    end)
    |> Map.new()
  end

  defp atomify_keys(list) when is_list(list) do
    list
    |> Enum.map(&atomify_keys/1)
  end

  defp atomify_keys(v), do: v
end
