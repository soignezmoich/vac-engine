defmodule VacEngine.Simulation.CasesTest do
  use VacEngine.DataCase

  alias VacEngine.Account
  alias VacEngine.Processor
  alias VacEngine.Repo
  alias VacEngine.Simulation
  alias VacEngine.Simulation.Case
  alias VacEngine.Simulation.Cases

  setup do
    # Create workspace for the whole test
    {:ok, workspace} = Account.create_workspace(%{name: "Test workspace"})

    # Create a blueprint with a stack and a template
    {:ok, original_blueprint} =
      Processor.create_blueprint(workspace, %{"name" => "Original"})

    {:ok, original_stack} =
      Simulation.create_blank_stack(original_blueprint, "Test_stack_case")

    preloaded_original_stack =
      original_stack
      |> Repo.preload(layers: [:case])

    original_case =
      preloaded_original_stack
      |> Map.get(:layers)
      |> List.first()
      |> Map.get(:case)

    {:ok, original_case: original_case}
  end

  test "Expect run error is set to ignore by default.", %{
    original_case: original_case
  } do
    assert original_case.expected_result == :ignore
  end

  test "expect_run_error is set to :error when expecting error.", %{
    original_case: original_case
  } do
    Cases.set_expect_run_error(original_case, true)

    modified_case = Repo.get(Case, original_case.id)

    assert modified_case.expected_result == :error
  end

  test "expect_run_error is set to :ignore when not expecting error.", %{
    original_case: original_case
  } do
    Cases.set_expect_run_error(original_case, true)
    modified_case = Repo.get(Case, original_case.id)
    Cases.set_expect_run_error(modified_case, false)
    final_case = Repo.get(Case, original_case.id)

    assert final_case.expected_result == :ignore
  end
end
