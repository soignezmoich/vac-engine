defmodule VacEngine.Processor.ProcessorTest do
  use VacEngine.DataCase

  alias VacEngine.Account
  alias VacEngine.Processor

  setup_all do
    [
      blueprints: Fixtures.Blueprints.blueprints(),
      cases: Fixtures.Cases.cases()
    ]
  end

  test "run cases", %{blueprints: blueprints, cases: cases} do
    {:ok, workspace} = Account.create_workspace(%{name: "Test workspace"})

    processors =
      blueprints
      |> Enum.map(fn {name, blueprint} ->
        assert {:ok, blueprint} =
                 Processor.create_blueprint(workspace, blueprint)

        blueprint =
          Processor.get_blueprint!(blueprint.id, fn query ->
            query
            |> Processor.load_blueprint_variables()
            |> Processor.load_blueprint_full_deductions()
          end)

        assert {:ok, processor} = Processor.compile_blueprint(blueprint)
        {name, processor}
      end)
      |> Map.new()

    cases
    |> Enum.map(fn cs ->
      assert {:ok, processor} = Map.fetch(processors, cs.blueprint)

      {res, actual_result} =
        Processor.run(processor, cs.input, Map.get(cs, :env))

      if Map.has_key?(cs, :error) do
        assert res == :error
        assert actual_result == cs.error
      else
        assert res == :ok
        assert actual_result.output == cs.output
      end
    end)

    processors
    |> Enum.each(fn {_name, processor} ->
      Processor.flush_processor(processor)
    end)

    assert Processor.list_compiled_blueprint_modules() == []
  end
end
