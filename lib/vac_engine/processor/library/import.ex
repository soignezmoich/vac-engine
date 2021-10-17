defmodule VacEngine.Processor.Library.Import do
  defmacro __using__(_opts) do
    quote do
      require VacEngine.Processor.Library.Functions

      @functions VacEngine.Processor.Library.Functions.__info__(:attributes)
                 |> Keyword.get(:functions)
                 |> Enum.at(0)

      def functions() do
        @functions
      end
    end
  end
end
