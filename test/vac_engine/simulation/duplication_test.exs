defmodule VacEngine.Simulation.DuplicationTest do
  @moduledoc """
  This module tests several duplications:
  1. whole blueprint duplication
  2. template case fork
  3. stack case fork
  """

  use VacEngine.DataCase

  alias VacEngine.Account
  alias VacEngine.Processor
  alias VacEngine.Repo
  alias VacEngine.Simulation
  alias VacEngine.Simulation.Case

  setup do
    # Create workspace for the whole test
    {:ok, workspace} = Account.create_workspace(%{name: "Test workspace"})

    # Create a blueprint with a stack and a template
    {:ok, original_blueprint} =
      Processor.create_blueprint(workspace, %{"name" => "Original"})

    {:ok, original_stack} =
      Simulation.create_blank_stack(original_blueprint, "Test_stack_case")

    {:ok, original_template} =
      Simulation.create_blank_template(original_blueprint, "Test_template_case")

    preloaded_original_stack =
      original_stack
      |> Repo.preload(layers: [:case])

    preloaded_original_template =
      original_template
      |> Repo.preload(:case)

    # Use the template for the stack
    Simulation.set_stack_template(
      preloaded_original_stack,
      preloaded_original_template.case_id
    )

    # Duplicate the blueprint
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

  test "After template case fork, case is not shared anymore and uses the new name.",
       setup do
    new_name = "forked"

    # Fork original template case
    original_template =
      setup[:original_blueprint]
      |> Map.get(:templates)
      |> List.first()

    original_case =
      original_template
      |> Map.get(:case)

    {:ok, final_case} =
      Simulation.fork_template_case(original_template, new_name)

    # Extract updated situation and assert result
    updated_template =
      original_template.id
      |> Simulation.get_template()
      |> Repo.preload(:case)

    original_stack =
      setup[:original_blueprint]
      |> Map.get(:stacks)
      |> List.first()

    updated_stack =
      original_stack
      |> Map.get(:id)
      |> Simulation.get_stack()
      |> Repo.preload(layers: [:case])

    updated_stack_template_case =
      Simulation.get_stack_template_case(updated_stack)

    assert updated_template.case_id != original_case.id
    assert updated_template.case_id == final_case.id
    assert updated_template.case.name == new_name
    assert updated_stack_template_case.id == final_case.id
  end

  test "After runnable case fork, case is not shared anymore and uses the new name.",
       setup do
    new_name = "forked2"

    # Fork original runnable case
    original_stack =
      setup[:original_blueprint]
      |> Map.get(:stacks)
      |> List.first()

    original_case = Simulation.get_stack_runnable_case(original_stack)

    {:ok, final_case} = Simulation.fork_runnable_case(original_stack, new_name)

    # Extract final situation and assert
    updated_stack = Simulation.get_stack(original_stack.id)

    updated_case = Simulation.get_stack_runnable_case(updated_stack)

    assert updated_case.id != original_case.id
    assert updated_case.id == final_case.id
    assert updated_case.name == new_name
  end
end
