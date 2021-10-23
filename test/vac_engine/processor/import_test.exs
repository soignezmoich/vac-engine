defmodule VacEngine.Processor.ImportTest do
  use VacEngine.DataCase

  alias VacEngine.Processor
  alias VacEngine.Account

  setup_all do
    [blueprints: Fixtures.Blueprints.blueprints()]
  end

  setup do
    Repo.query("delete from publications;")
    Repo.query("delete from blueprints;")
    Repo.query("delete from roles;")
    Repo.query("delete from portals;")
    {:ok, workspace} = Account.create_workspace(%{name: "Test workspace"})
    [workspace: workspace]
  end

  test "serialize", %{workspace: workspace, blueprints: blueprints} do
    assert {:ok, blueprint} =
             Processor.create_blueprint(workspace, blueprints.ruleset0)

    serialized = Processor.serialize_blueprint(blueprint)

    assert {:ok, blueprint} =
             Processor.update_blueprint(blueprint, serialized)

    serialized_two = Processor.serialize_blueprint(blueprint)

    assert serialized == serialized_two

    assert {:ok, blueprint} =
             Processor.create_blueprint(workspace, serialized)

    serialized_two = Processor.serialize_blueprint(blueprint)

    assert serialized == serialized_two
  end
end
