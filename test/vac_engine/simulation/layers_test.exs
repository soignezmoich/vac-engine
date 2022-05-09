defmodule VacEngine.Simulation.LayersTest do
  use VacEngine.DataCase

  alias VacEngine.Account
  alias VacEngine.Processor
  alias VacEngine.Repo
  alias VacEngine.Simulation
  alias VacEngine.Simulation.Layers

  setup do
    # Create workspace for the whole test
    {:ok, workspace} = Account.create_workspace(%{name: "Test workspace"})

    # Create a blueprint with a stack and a template
    {:ok, original_blueprint} =
      Processor.create_blueprint(workspace, %{"name" => "Original"})

    {:ok, duplicated_stack} =
      Simulation.create_blank_stack(original_blueprint, "Duplicated")

    duplicated_layer =
      duplicated_stack
      |> Repo.preload(:layers)
      |> Map.fetch!(:layers)
      |> List.first()

    # Duplicate the blueprint
    {:ok, copy_blueprint} = Processor.duplicate_blueprint(original_blueprint)

    {:ok, single_stack} =
      Simulation.create_blank_stack(original_blueprint, "Single")

    single_layer =
      single_stack
      |> Repo.preload(:layers)
      |> Map.fetch!(:layers)
      |> List.first()

    {
      :ok,
      original_blueprint: original_blueprint,
      copy_blueprint: copy_blueprint,
      duplicated_layer: duplicated_layer,
      single_layer: single_layer
    }
  end

  test "blueprint sharing layer cases properly retrieved",
       %{
         duplicated_layer: duplicated_layer,
         copy_blueprint: copy_blueprint
       } do
    sharing_blueprints =
      Layers.get_blueprints_sharing_layer_case(duplicated_layer)

    copy_blueprint_info = %{
      blueprint_id: copy_blueprint.id,
      blueprint_name: copy_blueprint.name
    }

    assert sharing_blueprints == [copy_blueprint_info]
  end

  test "blueprint not sharing layer absent", %{single_layer: single_layer} do
    sharing_blueprints =
      Layers.get_blueprints_sharing_layer_case(single_layer)

    assert sharing_blueprints == []
  end
end
