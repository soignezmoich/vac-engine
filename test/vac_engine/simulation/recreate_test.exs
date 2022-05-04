defmodule VacEngine.Simulation.RecreateTest do
  use VacEngine.DataCase

  alias VacEngine.Account
  alias VacEngine.Processor
  alias VacEngine.Repo
  alias VacEngine.Simulation
  alias VacEngine.Simulation.Case

  setup do
    {:ok, workspace} = Account.create_workspace(%{name: "Test workspace"})

    {:ok, original_blueprint} =
      Processor.create_blueprint(workspace, %{"name" => "Original"})

    serialized_blueprint =
      original_blueprint.id
      |> Processor.get_full_blueprint!(true)
      |> Processor.serialize_blueprint()

    Simulation.create_blank_stack(original_blueprint, "Test_stack_case")

    Processor.recreate_blueprint(original_blueprint, serialized_blueprint)

    recreated_blueprint =
      original_blueprint
      |> Repo.preload(stacks: [layers: [:case]])
      |> Repo.preload(templates: [:case])

    {:ok, recreated_blueprint: recreated_blueprint}
  end

  test "After recreation, no previous element is kept.", setup do
    recreated_blueprint_stacks =
      setup[:recreated_blueprint]
      |> Map.get(:stacks)

    assert recreated_blueprint_stacks == []
  end

end
