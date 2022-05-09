defmodule VacEngine.Simulation.Layers do
  @moduledoc false

  import Ecto.Query

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
end
