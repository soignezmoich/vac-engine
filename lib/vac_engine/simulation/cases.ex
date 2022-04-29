defmodule VacEngine.Simulation.Cases do
  import Ecto.Changeset

  alias VacEngine.Repo

  def set_expect_run_error(kase, expect_run_error) do
    expected_result =
      if expect_run_error do
        :error
      else
        :ignore
      end

    kase
    |> cast(%{expected_result: expected_result}, [:expected_result])
    |> Repo.update()
  end
end
