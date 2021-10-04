defmodule VacEngine.ProcessorCase do
  use ExUnit.CaseTemplate

  using do
    quote do
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

      defp stringify_keys(v), do: v

    end
  end
end
