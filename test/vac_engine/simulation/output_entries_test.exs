defmodule VacEngine.Simulation.OutputEntriesTest do
  use VacEngine.DataCase

  alias VacEngine.Account
  alias VacEngine.Processor
  alias VacEngine.Repo
  alias VacEngine.Simulation
  alias VacEngine.Simulation.OutputEntries
  alias VacEngine.Simulation.OutputEntry

  setup do
    # Create workspace for the whole test
    {:ok, workspace} = Account.create_workspace(%{name: "Test workspace"})

    # Create a blueprint with a stack and a template
    {:ok, blueprint} =
      Processor.create_blueprint(workspace, %{"name" => "Original"})

    {:ok, variable} =
      Processor.create_variable(blueprint, %{
        name: "gender",
        type: :string,
        enum: ["f", "m"]
      })

    {:ok, stack} = Simulation.create_blank_stack(blueprint, "Test_stack_case")

    preloaded_stack = Repo.preload(stack, layers: [:case])

    kase =
      preloaded_stack
      |> Map.get(:layers)
      |> List.first()
      |> Map.get(:case)

    {:ok, kase: kase, variable: variable}
  end

  test "Output entry is properly created.", %{kase: kase, variable: variable} do
    OutputEntries.create_output_entry(kase, "gender", variable)
    entries = Repo.all(OutputEntry)
    created_entry = entries |> List.first()

    assert created_entry.case_id == kase.id
    assert created_entry.key == "gender"
    assert created_entry.expected == "f"
    assert created_entry.forbid == false
    assert length(entries) == 1
  end

  test "Output entry is properly deleted", %{kase: kase, variable: variable} do
    {:ok, entry} = OutputEntries.create_output_entry(kase, "gender", variable)
    OutputEntries.delete_output_entry(entry)
    entries = Repo.all(OutputEntry)

    assert length(entries) == 0
  end

  test "Output entry 'expected' is properly set if matches possible values.", %{
    kase: kase,
    variable: variable
  } do
    OutputEntries.create_output_entry(kase, "gender", variable)
    created_entry = Repo.all(OutputEntry) |> List.first()
    OutputEntries.set_expected(created_entry, "m")
    final_entry = Repo.all(OutputEntry) |> List.first()

    assert final_entry.expected == "m"
  end

  # Expected value is currently not forced to match the variable content.
  # This is intentional so tests are not coupled to the variables themselves.
  # It might be modified in the future.
  test "Output entry 'expected' update is rejected if value is not possible.",
       %{kase: kase, variable: variable} do
    OutputEntries.create_output_entry(kase, "gender", variable)
    created_entry = Repo.all(OutputEntry) |> List.first()
    OutputEntries.set_expected(created_entry, "bim")
    final_entry = Repo.all(OutputEntry) |> List.first()

    assert final_entry.expected == "bim"
  end

  test "Forbidden can be toggled to true", %{kase: kase, variable: variable} do
    OutputEntries.create_output_entry(kase, "gender", variable)
    created_entry = Repo.all(OutputEntry) |> List.first()
    OutputEntries.toggle_forbidden(created_entry, true)
    final_entry = Repo.all(OutputEntry) |> List.first()

    assert final_entry.forbid == true
  end

  test "Forbidden can be toggled to false", %{kase: kase, variable: variable} do
    OutputEntries.create_output_entry(kase, "gender", variable)
    entry1 = Repo.all(OutputEntry) |> List.first()
    OutputEntries.toggle_forbidden(entry1, true)
    entry2 = Repo.all(OutputEntry) |> List.first()
    OutputEntries.toggle_forbidden(entry2, false)
    final_entry = Repo.all(OutputEntry) |> List.first()

    assert final_entry.forbid == false
  end

  test "Forbidden is set to false when expected is set", %{
    kase: kase,
    variable: variable
  } do
    OutputEntries.create_output_entry(kase, "gender", variable)
    entry1 = Repo.all(OutputEntry) |> List.first()
    OutputEntries.toggle_forbidden(entry1, true)
    entry2 = Repo.all(OutputEntry) |> List.first()
    OutputEntries.set_expected(entry2, "m")
    final_entry = Repo.all(OutputEntry) |> List.first()

    assert final_entry.expected == "m"
    assert final_entry.forbid == false
  end
end
