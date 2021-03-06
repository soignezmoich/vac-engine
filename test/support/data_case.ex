defmodule VacEngine.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use VacEngine.DataCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias VacEngine.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Fixtures.Helpers
      import VacEngine.DataCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(VacEngine.Repo)

    VacEngine.Repo.query("select setval('workspaces_id_seq',
      (select last_value from workspaces_id_seq) + #{:rand.uniform(500)});")
    VacEngine.Repo.query("select setval('portals_id_seq',
      (select last_value from portals_id_seq) + #{:rand.uniform(100)});")
    VacEngine.Repo.query("select setval('blueprints_id_seq',
      (select last_value from blueprints_id_seq) + #{:rand.uniform(50)});")

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(VacEngine.Repo, {:shared, self()})
    end

    :ok
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
