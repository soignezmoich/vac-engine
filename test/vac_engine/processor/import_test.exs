defmodule VacEngine.Processor.ImportTest do
  @moduledoc false

  use VacEngine.DataCase

  alias VacEngine.Processor
  alias VacEngine.Account
  alias VacEngine.Processor.Binding
  import Ecto.Query

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
             Processor.create_blueprint(workspace, blueprints.nested_test)

    serialized = Processor.serialize_blueprint(reload(blueprint))

    assert {:ok, blueprint} = Processor.update_blueprint(blueprint, serialized)

    serialized_two = Processor.serialize_blueprint(reload(blueprint))

    assert serialized == serialized_two

    assert {:ok, blueprint} = Processor.create_blueprint(workspace, serialized)

    serialized_two = Processor.serialize_blueprint(reload(blueprint))

    assert serialized == serialized_two

    assert {:ok, blueprint} =
             Processor.create_blueprint(workspace, blueprints.sig_test)

    serialized = Processor.serialize_blueprint(reload(blueprint))

    blueprint = reload(blueprint)

    now = DateTime.truncate(DateTime.utc_now(), :second)

    [binding] =
      get_in(
        blueprint,
        [
          Access.key(:deductions),
          Access.at(0),
          Access.key(:branches),
          Access.at(0),
          Access.key(:assignments),
          Access.at(0),
          Access.key(:expression),
          Access.key(:bindings),
          Access.filter(fn b -> b.position == 0 end)
        ]
      )

    from(b in Binding, where: b.id == ^binding.id)
    |> VacEngine.Repo.update_all(set: [updated_at: now])

    blueprint = reload(blueprint)

    serialized_two = Processor.serialize_blueprint(blueprint)

    assert serialized == serialized_two
  end

  def reload(blueprint) do
    Processor.get_blueprint!(blueprint.id, fn query ->
      query
      |> Processor.load_blueprint_variables()
      |> Processor.load_blueprint_full_deductions()
      |> Processor.load_blueprint_simulation(true)
    end)
  end
end
