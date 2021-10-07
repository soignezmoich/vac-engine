defmodule VacEngine.Processor.BlueprintTest do
  use VacEngine.ProcessorCase

  import Fixtures.Blueprints
  import Fixtures.Cases
  alias VacEngine.Processor
  alias VacEngine.Processor
  alias VacEngine.Processor.Blueprint

  @hashes %{
    "SF38ZPKGHC48F674EYF9522367HXC9C8ZF2EKF7HG3CT9R622B2SWYZ8" => [
      :hash0_test,
      :hash1_test,
      :hash2_test
    ],
    "EZF7B46RYZHA6X8EH6ZTBS6P6EEE4XSRSC4FW629C9WYC5PB4FXRHT76" => [:hash3_test]
  }

  test "run cases" do
    brs =
      blueprints()
      |> Enum.map(fn {name, blueprint} ->
        assert {:ok, blueprint} =
                 Processor.change_blueprint(%Blueprint{}, blueprint)
                 |> Ecto.Changeset.apply_action(:insert)

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
