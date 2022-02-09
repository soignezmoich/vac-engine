defmodule VacEngine.Pub.ReadonlyTest do
  use VacEngine.DataCase

  alias VacEngine.Account
  alias VacEngine.Processor
  alias VacEngine.Pub

  setup do
    Repo.query("delete from publications;")
    Repo.query("delete from blueprints;")
    Repo.query("delete from roles;")
    Repo.query("delete from portals;")
    {:ok, workspace} = Account.create_workspace(%{name: "Test workspace"})
    [workspace: workspace]
  end

  test "readonly blueprint not loaded", %{
    workspace: workspace
  } do
    {:ok, blueprint} =
      Processor.create_blueprint(workspace, %{"name" => "test_blueprint"})

    Pub.publish_blueprint(blueprint, %{"name" => "test_portal"})

    assert Processor.blueprint_readonly?(blueprint)
  end

  test "not readonly blueprint not loaded", %{
    workspace: workspace
  } do
    {:ok, blueprint} =
      Processor.create_blueprint(workspace, %{"name" => "test_blueprint"})

    assert !Processor.blueprint_readonly?(blueprint)
  end

  test "readonly blueprint loaded", %{
    workspace: workspace
  } do
    {:ok, blueprint} =
      Processor.create_blueprint(workspace, %{"name" => "test_blueprint"})

    Pub.publish_blueprint(blueprint, %{"name" => "test_portal"})

    assert Processor.blueprint_readonly?(
             blueprint
             |> Repo.preload(:publications)
           )
  end

  test "not readonly blueprint loaded", %{
    workspace: workspace
  } do
    {:ok, blueprint} =
      Processor.create_blueprint(workspace, %{"name" => "test_blueprint"})

    assert !Processor.blueprint_readonly?(
             blueprint
             |> Repo.preload(:publications)
           )
  end
end
