defmodule VacEngine.Simulation.Simulations do
  alias VacEngine.Repo
  alias VacEngine.Simulation.Case

  def create_case(attrs) do
    Case.changeset(
      %Case{},
      attrs
    )
    |> Repo.insert_or_update()
  end
end
