defmodule VacEngine.Processor.ProcessorTest do
  use VacEngine.DataCase

  import Fixtures.Blueprints
  import Fixtures.Cases
  alias VacEngine.Account
  alias VacEngine.Processor
  alias VacEngine.Processor
  alias VacEngine.Processor.Blueprint

  test "run cases" do
    {:ok, workspace} = Account.create_workspace(%{name: "Test workspace"})

    processors =
      blueprints()
      |> Enum.filter(fn {name, blueprint} -> name == :ruleset0 end)
      |> Enum.map(fn {name, blueprint} ->
        assert {:ok, blueprint} =
                 Processor.create_blueprint(workspace, blueprint)

        assert {:ok, processor} = Processor.compile_blueprint(blueprint)
        {name, processor}
      end)
      |> Map.new()

    cases()
    |> Enum.filter(fn cs -> cs.blueprint == :ruleset0 end)
    |> Enum.map(fn cs ->
      assert {:ok, processor} = Map.fetch(processors, cs.blueprint)
      input = smap(cs.input)
      expected_result = smap(cs.output)
      assert {:ok, actual_result} = Processor.run(processor, input)
      assert actual_result.output == expected_result
    end)
  end
end
