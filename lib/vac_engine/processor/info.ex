defmodule VacEngine.Processor.Info do
  alias VacEngine.Processor.Info
  alias VacEngine.Processor.Info.Schema
  alias VacEngine.Processor.Info.Logic

  defstruct output: %{}, input: %{}, logic: nil

  def describe(blueprint) do
    input_schema = Schema.input_schema(blueprint)
    output_schema = Schema.output_schema(blueprint)
    logic = Logic.logic(blueprint)

    {:ok, %Info{input: input_schema, output: output_schema, logic: logic}}
  end
end
