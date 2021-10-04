defmodule VacEngine.ProcessorCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      def smap(map) do
        map |> Jason.encode!() |> Jason.decode!()
      end
    end
  end
end
