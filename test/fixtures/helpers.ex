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

    defmacro vars(name, do: block) do
      quote do
        def unquote(:"blueprint_vars__#{name}")() do
          unquote(block)
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

        def blueprint_vars() do
          __MODULE__.__info__(:functions)
          |> Enum.reduce(
            %{},
            fn {func, _}, map ->
              case to_string(func) do
                "blueprint_vars__" <> name ->
                  name = String.to_existing_atom(name)
                  Map.put(map, name, apply(__MODULE__, func, []))

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

  defmodule Simulations do
    defmacro sim(do: block) do
      name = :crypto.strong_rand_bytes(8) |> Base24.encode24()

      quote do
        def unquote(:"simulation__#{name}")() do
          unquote(block)
        end
      end
    end

    defmacro __using__(_opts) do
      quote do
        import Fixtures.Helpers.Simulations
        Module.register_attribute(__MODULE__, :simulations, accumulate: true)

        def simulations() do
          __MODULE__.__info__(:functions)
          |> Enum.reduce(
            [],
            fn {func, _}, res ->
              case to_string(func) do
                "simulation__" <> name ->
                  data =
                    apply(__MODULE__, func, [])
                    |> Map.put(:name, name)

                  data = %{
                    error: Map.get(data, :error),
                    name: name,
                    blueprint: data.blueprint,
                    stack:
                      Map.get(data, :stack) ||
                        Fixtures.Helpers.extract_stack(data),
                    result: Fixtures.Helpers.extract_result(data)
                  }

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

  def extract_stack(sim) do
    input_case =
      case sim do
        %{input: %{} = input} ->
          input
          |> Enum.map(fn {k, v} ->
            %{key: to_string(k), value: to_string(v)}
          end)
          |> then(fn entries ->
            %{name: "case_#{sim.name}_input", input_entries: entries}
          end)

        _ ->
          nil
      end

    output_case =
      case sim do
        %{result: %{} = res} ->
          res
          |> Enum.map(fn {k, v} ->
            case v do
              %{expected: e} when not is_nil(e) ->
                %{expected: to_string(e)}

              _ ->
                %{}
            end
            |> Map.merge(%{
              key: k,
              forbid: Map.get(v, :forbid)
            })
          end)
          |> then(fn entries ->
            %{name: "case_#{sim.name}_output", output_entries: entries}
          end)

        _ ->
          nil
      end

    result_case =
      case sim do
        %{error: error} ->
          %{
            name: "case_#{sim.name}_error",
            expected_error: error,
            expected_result: :error
          }

        _ ->
          nil
      end

    layers =
      [input_case, output_case, result_case]
      |> Enum.reject(&is_nil/1)
      |> Enum.map(fn kase ->
        %{case: kase}
      end)

    %{
      active: true,
      layers: layers
    }
    |> smap()
  end

  def extract_result(sim) do
    case sim do
      %{result: %{} = res} ->
        res
        |> Enum.map(fn {k, v} ->
          path =
            k
            |> to_string()
            |> String.split(".")

          v =
            case v do
              %{expected: e} when not is_nil(e) ->
                Map.put(v, :expected, to_string(e))

              _ ->
                Map.pop(v, :expected)
                |> elem(1)
            end

          {path, v}
        end)
        |> Map.new()

      _ ->
        %{}
    end
  end
end
