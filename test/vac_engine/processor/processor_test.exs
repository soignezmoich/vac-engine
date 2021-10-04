defmodule VacEngine.Processor.ProcessorTest do
  use VacEngine.ProcessorCase

  import Fixtures.Blueprints
  import Fixtures.Cases
  alias VacEngine.Processor
  alias VacEngine.Blueprints
  alias VacEngine.Blueprints.Blueprint

  test "run cases" do
    processors =
      blueprints()
      |> Enum.map(fn blueprint ->
        assert {:ok, blueprint} =
                 Blueprints.change_blueprint(%Blueprint{}, blueprint)
                 |> Ecto.Changeset.apply_action(:insert)

        assert {:ok, processor} = Processor.compile_blueprint(blueprint)
        {blueprint.name, processor}
      end)
      |> Map.new()

    cases()
    |> Enum.map(fn cs ->
      assert {:ok, processor} = Map.fetch(processors, to_string(cs.blueprint))
      input = smap(cs.input)
      expected_result = smap(cs.output)
      assert {:ok, ^expected_result} = Processor.run(processor, input)
    end)
  end
end
