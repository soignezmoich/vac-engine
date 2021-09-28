defmodule VacEngine.Processor.ProcessorTest do
  use ExUnit.Case

  alias Fixtures.Blueprints
  alias Fixtures.Cases
  alias VacEngine.Processor
  alias VacEngine.Processor.Blueprint

  test "run cases" do
    processors =
      Blueprints.blueprints()
      |> Enum.map(fn blueprint ->
        assert {:ok, blueprint} =
                 Processor.update_blueprint(%Blueprint{}, blueprint)
                 |> Ecto.Changeset.apply_action(:insert)

        assert {:ok, processor} = Processor.compile_blueprint(blueprint)
        {blueprint.name, processor}
      end)
      |> Map.new()

    Cases.cases()
    |> Enum.map(fn cs ->
      assert {:ok, processor} = Map.fetch(processors, to_string(cs.blueprint))
      result = Map.new(cs.output, fn {k, v} -> {to_string(k), v} end)
      assert {:ok, ^result} = Processor.run(processor, cs.input)
    end)
  end
end
