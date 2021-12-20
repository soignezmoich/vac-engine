defmodule Fixtures.Helpers do
  defmodule Blueprints do
    defmacro blueprint(name, do: block) do
      quote do
        def unquote(:"blueprint__#{name}")() do
          Map.merge(
            %{name: unquote(name), deductions: [], variables: []},
            unquote(block)
          )
        end
      end
    end

    defmacro __using__(_opts) do
      quote do
        import Fixtures.Helpers.Blueprints

        def blueprints() do
          __MODULE__.__info__(:functions)
          |> Enum.reduce(
            %{},
            fn {func, _}, map ->
              case to_string(func) do
                "blueprint__" <> name ->
                  name = String.to_existing_atom(name)
                  Map.put(map, name, apply(__MODULE__, func, []) |> smap())

                _ ->
                  map
              end
            end
          )
        end
      end
    end
  end

  defmodule Cases do
    defmacro cas(br, do: block) do
      name = :crypto.strong_rand_bytes(8) |> Base24.encode24()

      quote do
        def unquote(:"case__#{name}")() do
          Map.merge(
            %{blueprint: unquote(br)},
            unquote(block)
          )
        end
      end
    end

    defmacro __using__(_opts) do
      quote do
        import Fixtures.Helpers.Cases
        Module.register_attribute(__MODULE__, :cases, accumulate: true)

        def cases() do
          __MODULE__.__info__(:functions)
          |> Enum.reduce(
            [],
            fn {func, _}, res ->
              case to_string(func) do
                "case__" <> name ->
                  data =
                    apply(__MODULE__, func, [])
                    |> update_in([:input], &smap/1)
                    |> update_in([:output], &smap/1)

                  [data | res]

                _ ->
                  res
              end
            end
          )
        end
      end
    end
  end

  def smap(map) do
    map
    |> stringify_keys()
  end

  defp stringify_keys(v) when is_struct(v, Date), do: v
  defp stringify_keys(v) when is_struct(v, DateTime), do: v
  defp stringify_keys(v) when is_struct(v, NaiveDateTime), do: v

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
  defp stringify_keys(v) when is_nil(v), do: v
  defp stringify_keys(v) when is_atom(v), do: to_string(v)
  defp stringify_keys(v), do: v

  def amap(map) do
    map
    |> atomify_keys()
  end

  defp atomify_keys(v) when is_struct(v, Date), do: v
  defp atomify_keys(v) when is_struct(v, DateTime), do: v
  defp atomify_keys(v) when is_struct(v, NaiveDateTime), do: v

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
