defmodule VacEngine.Processor.Info do
  @moduledoc """
  Produces the description of a processor from it's blueprint description.
  The information provided by this module correspond to the
  `VacEngine.Pub.info_cached/1` function and the `GET info` API endpoint.

  The info provided includes **input**, **output** and **logic** of the
  processor:

      {:ok, %Info{input: input_schema, output: output_schema, logic: logic}} =
        Info.describe(blueprint)

  ## Input schema

  The Json Schema representation of the input accepted by the processor
  (see: https://json-schema.org/).

  ## Output schema

  The Json Schema representation of the output returned by the processor.

  ## Logic description

  The logic description gives an overview of the logic involved in the
  processor. It is by no mean a full description of the processor behaviour.
  It is more a description of the way certain variables chosen by the editor
  are deduced.

  Technically, a deduction description is provided only if the editor added
  a description to the assignments of this variable (see `VacEngine.Processor`
  documentation for more information about assignments).

  Logic description appear as a 3 layers structure: a map keyed by variable
  names, whose values are maps keyes by possible values, each containing
  a list the descriptions gathered from the assignments
  """
  alias VacEngine.Processor.Info
  alias VacEngine.Processor.Info.Schema
  alias VacEngine.Processor.Info.Logic

  defstruct output: %{}, input: %{}, logic: nil

  @doc """
  Provide the complete description of a blueprint.

  The description contains the input, output and logic of the blueprint.
  """
  def describe(blueprint) do
    input_schema = Schema.input_schema(blueprint)
    output_schema = Schema.output_schema(blueprint)
    logic = Logic.logic(blueprint)

    {:ok, %Info{input: input_schema, output: output_schema, logic: logic}}
  end
end
