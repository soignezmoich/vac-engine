defmodule VacEngine.Simulation.Layers do
  import Ecto.Changeset
  import Ecto.Query

  alias Ecto.Multi
  alias VacEngine.Repo
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Simulation.Case
  alias VacEngine.Simulation.Layer

  def get_blueprints_sharing_layer_case(%Layer{} = layer) do
    from(l in Layer,
      join: c in Case,
      on: l.case_id == c.id,
      join: b in Blueprint,
      on: l.blueprint_id == b.id,
      where: l.case_id == ^layer.case_id and l.id != ^layer.id,
      select: %{blueprint_name: b.name, blueprint_id: b.id}
    )
    |> Repo.all()
  end

  def fork_layer_case(%Layer{} = layer, name) do
    original_case =
      layer
      |> Repo.preload([:input_entries, :output_entries])

    Multi.new()
    |> Multi.insert(:new_case, fn _ ->
      ctx = %{workspace_id: original_case.workspace_id}

      Case.nested_changeset(%Case{}, Case.to_map(original_case), ctx)
      |> change(%{name: name})
    end)
    |> Multi.update(:layer, fn %{new_case: new_case} ->
      layer
      |> change(%{case_id: new_case.id})
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{new_case: new_case}} -> {:ok, new_case}
      other -> other
    end
  end
end
