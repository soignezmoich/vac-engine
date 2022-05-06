defmodule VacEngine.Processor.InfoTest do
  @moduledoc false

  use VacEngine.DataCase

  alias VacEngine.Processor.Info
  alias VacEngine.Processor
  alias VacEngine.Account

  setup_all do
    [blueprints: Fixtures.Blueprints.blueprints()]
  end

  setup do
    {:ok, workspace} = Account.create_workspace(%{name: "Test workspace"})
    [workspace: workspace]
  end

  test "basic info", %{blueprints: blueprints, workspace: workspace} do
    brs =
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

        {name, blueprint}
      end)
      |> Map.new()

    br = Map.get(brs, :nested_test)

    assert {:ok, _} = Info.describe(br)
  end
end
