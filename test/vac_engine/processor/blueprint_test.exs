defmodule VacEngine.Processor.BlueprintTest do
  use VacEngine.DataCase

  import Fixtures.Blueprints
  import Fixtures.Cases
  alias VacEngine.Account
  alias VacEngine.Processor
  alias VacEngine.Processor
  alias VacEngine.Processor.Blueprint

  @hashes %{
    "7XZBRP9BZ7KX564ZAX7FTAXBYPRCG68E8S2TY4XESZSRSF36G4ASF55S" => [
      :hash0_test,
      :hash1_test,
      :hash2_test
    ],
    "RKBZZXY82ZXTYS29EEB3YBC5R2FP7HKBGZY6AY4CB87H63T8T5X7WT95" => [:hash3_test]
  }

  test "run cases" do
    {:ok, workspace} = Account.create_workspace(%{name: "Test workspace"})

    brs =
      blueprints()
      |> Enum.map(fn {name, blueprint} ->
        assert {:ok, blueprint} =
                 Processor.create_blueprint(workspace, blueprint)

        {name, blueprint}
      end)
      |> Map.new()

    for {n, keys} <- @hashes do
      for k <- keys do
        br = Map.get(brs, k)
        assert n == br.interface_hash
      end
    end
  end
end
