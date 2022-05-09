defmodule VacEngine.Simulation.InputEntriesTest do
  use VacEngine.DataCase

  alias VacEngine.Account
  alias VacEngine.Processor
  alias VacEngine.Repo
  alias VacEngine.Simulation
  alias VacEngine.Simulation.InputEntries
  alias VacEngine.Simulation.InputEntry

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

  test "Input entry is properly created.", %{kase: kase} do
    InputEntries.create_input_entry(kase, "gender")

    entries = Repo.all(InputEntry)
    created_entry = entries |> List.first()

    assert created_entry.case_id == kase.id
    assert created_entry.key == "gender"
    assert created_entry.value == "-"
    assert length(entries) == 1
  end

  test "Input entry is properly deleted", %{kase: kase} do
    {:ok, entry} = InputEntries.create_input_entry(kase, "gender")
    InputEntries.delete_input_entry(entry)

    entries = Repo.all(InputEntry)

    assert length(entries) == 0
  end

  test "Input entry is properly updated", %{kase: kase, variable: variable} do
    {:ok, entry} = InputEntries.create_input_entry(kase, "gender")

    entry =
      entry
      |> Repo.preload([:workspace, :case])

    InputEntries.update_input_entry(entry, "f", variable)

    entries = Repo.all(InputEntry)
    created_entry = entries |> List.first()

    assert created_entry.case_id == kase.id
    assert created_entry.key == "gender"
    assert created_entry.value == "f"

    assert length(entries) == 1
  end

  test "Input entry update is rejected if out of variable enum values.", %{
    kase: kase,
    variable: variable
  } do
    {:ok, entry} = InputEntries.create_input_entry(kase, "gender")

    entry =
      entry
      |> Repo.preload([:workspace, :case])

    InputEntries.update_input_entry(entry, "rejected_value", variable)

    entries = Repo.all(InputEntry)
    created_entry = entries |> List.first()

    assert created_entry.case_id == kase.id
    assert created_entry.key == "gender"
    assert created_entry.value == "-"

    assert length(entries) == 1
  end
end
