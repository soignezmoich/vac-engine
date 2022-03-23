defmodule VacEngine.Simulation.Cases do

  import Ecto.Changeset
  import Ecto.Query

  alias VacEngine.Repo
  alias VacEngine.Simulation.Case

  def filter_cases_by_workspace(query, workspace) do
    from(b in query, where: b.workspace_id == ^workspace.id)
  end

  def get_case(case_id, queries) do
    Case
    |> queries.()
    |> Repo.get(case_id)
  end

  def get_case!(case_id, queries) do
    Case
    |> queries.()
    |> Repo.get!(case_id)
  end

  def list_cases(queries) do
    Case
    |> queries.()
    |> Repo.all()
  end

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
