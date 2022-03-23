defmodule VacEngine.Release do
  @moduledoc """
  This module is used in production to provide an interface to the app
  from the command line.
  """

  @app :vac_engine

  require Logger
  alias VacEngine.Account

  @doc """
  Run all migrations
  """
  def migrate do
    for repo <- repos() do
      {:ok, _, _} =
        Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  @doc """
  Rollback all migrations
  """
  def rollback(repo, version) do
    {:ok, _, _} =
      Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  @doc """
  Create an admin user
  """
  def create_admin() do
    {:ok, _, _} =
      Ecto.Migrator.with_repo(VacEngine.Repo, fn _ ->
        do_create_admin()
      end)
  end

  defp do_create_admin() do
    email = "admin@admin.local"

    pass =
      Account.generate_secret(12)
      |> String.downcase()
      |> String.slice(0..12)

    Account.create_user(%{
      "name" => "Default Admin",
      "email" => email,
      "password" => pass
    })
    |> case do
      {:ok, user} ->
        {:ok, _perm} = Account.grant_permission(user.role, :super_admin)

        Logger.info("""
        Admin account created.

        Log in with the following credentials:

        \t Email: #{email}
        \t Password: #{pass}
        """)

      {:error, %Ecto.Changeset{errors: errs}} ->
        Logger.error("Cannot create default admin user")

        Enum.each(errs, fn {field, {msg, _}} ->
          Logger.error("\t#{field}: #{msg}")
        end)

      {:error, err} ->
        Logger.error("Cannot create default admin user, unknown error")
        Logger.error(inspect(err))
    end
  end

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end
end
