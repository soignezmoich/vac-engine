defmodule VacEngine.Simulation.DuplicationTest do
  use VacEngine.DataCase

  alias VacEngine.Account
  alias VacEngine.Processor
  alias VacEngine.Repo
  alias VacEngine.Simulation
  alias VacEngine.Simulation.Case

  setup_all do
    {:ok, workspace} = Account.create_workspace(%{name: "Test workspace"})

    {:ok, original_blueprint} =
      Processor.create_blueprint(workspace, %{name: "Original"})

    Simulation.create_blank_stack(original_blueprint, "Test_stack_case")
    Simulation.create_blank_template(original_blueprint, "Test_template_case")

    {:ok, duplicated_blueprint} =
      Processor.duplicate_blueprint(original_blueprint)

    preloaded_original_blueprint =
      original_blueprint
      |> Repo.preload(stacks: [layers: [:case]])
      |> Repo.preload(templates: [:case])

    preloaded_duplicated_blueprint =
      duplicated_blueprint
      |> Repo.preload(stacks: [layers: [:case]])
      |> Repo.preload(templates: [:case])

    {:ok,
     original_blueprint: preloaded_original_blueprint,
     duplicated_blueprint: preloaded_duplicated_blueprint}
  end

  test "After duplication, stack is duplicated. Case is shared.", setup do
    original_stack =
      setup[:original_blueprint]
      |> Map.get(:stacks)
      |> List.first()

    original_layer =
      original_stack
      |> Map.get(:layers)
      |> List.first()

    original_case =
      original_layer
      |> Map.get(:case)

    duplicated_stack =
      setup[:duplicated_blueprint]
      |> Map.get(:stacks)
      |> List.first()

    duplicated_layer =
      duplicated_stack
      |> Map.get(:layers)
      |> List.first()

    shared_case =
      duplicated_layer
      |> Map.get(:case)

    assert duplicated_stack != original_stack
    assert duplicated_layer != original_layer
    assert shared_case == original_case
    assert %Case{} = shared_case
  end

  test "After duplicate, template is duplicated. Case is shared.", setup do
    original_template =
      setup[:original_blueprint]
      |> Map.get(:templates)
      |> List.first()

    original_case =
      original_template
      |> Map.get(:case)

    duplicated_template =
      setup[:duplicated_blueprint]
      |> Map.get(:templates)
      |> List.first()

    shared_case =
      duplicated_template
      |> Map.get(:case)

    assert duplicated_template != original_template
    assert shared_case == original_case
    assert %Case{} = shared_case
  end
end
