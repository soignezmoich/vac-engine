defmodule VacEngine.Simulation.DeleteOrphansTest do
  @moduledoc """
  This module tests that all and only orphans are delete when:
  1. a blueprint is deleted
  2. a stack is deleted
  3. a template is deleted
  """

  use VacEngine.DataCase

  alias VacEngine.Account
  alias VacEngine.Processor
  alias VacEngine.Repo
  alias VacEngine.Simulation
  alias VacEngine.Simulation.Case
  alias VacEngine.Simulation.Stack

  setup do
    # Create workspace for the whole test
    {:ok, workspace} = Account.create_workspace(%{name: "Test workspace"})

    # Create a blueprint with a stack and a template
    {:ok, original_blueprint} =
      Processor.create_blueprint(workspace, %{name: "Original"})

    {:ok, original_stack} =
      Simulation.create_blank_stack(original_blueprint, "test_stack_case")

    {:ok, original_template} =
      Simulation.create_blank_template(original_blueprint, "test_template_case")

    # Duplicate the blueprint
    {:ok, duplicated_blueprint} =
      Processor.duplicate_blueprint(original_blueprint)

    # Create one extra template and stack (not duplicated)
    {:ok, original_extra_stack} =
      Simulation.create_blank_stack(original_blueprint, "extra_stack_case")

    {:ok, original_extra_template} =
      Simulation.create_blank_template(
        original_blueprint,
        "extra_template_case"
      )

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
     duplicated_blueprint: preloaded_duplicated_blueprint,
     single_use_template: original_extra_template,
     multi_use_template: original_template,
     single_use_stack: original_extra_stack,
     multi_use_stack: original_stack}
  end

  test "When a template is deleted, cases that are not used anymore are deleted.",
       setup do
    Simulation.delete_template(setup.single_use_template)

    remaining_case_names =
      Repo.all(Case)
      |> Enum.map(& &1.name)

    assert remaining_case_names == [
             "test_stack_case",
             "test_template_case",
             "extra_stack_case"
           ]
  end

  test "When a template is deleted, cases that are still used are not deleted.",
       setup do
    Simulation.delete_template(setup.multi_use_template)

    remaining_case_names =
      Repo.all(Case)
      |> Enum.map(& &1.name)

    assert remaining_case_names == [
             "test_stack_case",
             "test_template_case",
             "extra_stack_case",
             "extra_template_case"
           ]
  end

  test "When a stack is deleted, cases that are not used anymore are deleted.",
       setup do
    Simulation.delete_stack(setup.single_use_stack)

    remaining_case_names =
      Repo.all(Case)
      |> Enum.map(& &1.name)

    assert remaining_case_names == [
             "test_stack_case",
             "test_template_case",
             "extra_template_case"
           ]
  end

  test "When a stack is deleted, cases that are still used are not deleted.",
       setup do
    Simulation.delete_stack(setup.multi_use_stack)

    remaining_case_names =
      Repo.all(Case)
      |> Enum.map(& &1.name)

    assert remaining_case_names == [
             "test_stack_case",
             "test_template_case",
             "extra_stack_case",
             "extra_template_case"
           ]
  end

  test "Stack is properly deleted when the case could not be deleted", setup do
    Simulation.delete_stack(setup.multi_use_stack)

    assert Repo.get(Stack, setup.multi_use_stack.id) == nil
  end

  test "When a blueprint is deleted, only cases that are not used anymore are deleted.",
       setup do
    Processor.delete_blueprint(setup.original_blueprint)

    remaining_case_names =
      Repo.all(Case)
      |> Enum.map(& &1.name)

    assert remaining_case_names == [
             "test_stack_case",
             "test_template_case"
           ]
  end
end
