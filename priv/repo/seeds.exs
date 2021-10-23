alias VacEngine.Pub
alias VacEngine.Account
alias VacEngine.Processor
alias Fixtures.Blueprints

VacEngine.Repo.query("delete from publications;")
VacEngine.Repo.query("delete from blueprints;")
VacEngine.Repo.query("delete from roles;")
VacEngine.Repo.query("delete from portals;")

blueprints = Blueprints.blueprints()

{:ok, {workspace, blueprint}} =
  VacEngine.Repo.transaction(fn ->
    email = "admin@admin.com"
    pass = Account.generate_secret(8) |> String.downcase() |> String.slice(0..8)

    {:ok, user} =
      Account.create_user(%{
        "name" => "Default Admin",
        "email" => email,
        "password" => pass
      })

    {:ok, _perm} = Account.grant_permission(user.role, :super_admin)

    {:ok, workspace} = Account.create_workspace(%{name: "Test workspace"})

    {time, {:ok, blueprint}} =
      :timer.tc(fn ->
        Processor.create_blueprint(
          workspace,
          blueprints.ruleset0
        )
      end)

    {:ok, _publication} = Pub.publish_blueprint(blueprint)

    {:ok, role} = Account.create_role(:api)
    {:ok, _perm} = Account.grant_permission(role, :super_admin)
    {:ok, api_token} = Account.create_api_token(role)

    IO.puts("###########################")
    IO.puts("Elapsed time to create blueprint: #{time / 1000}ms")
    IO.puts("Created admin account with email/password: #{email} / #{pass}")
    IO.puts("Created api key: #{api_token.secret}")

    {workspace, blueprint}
  end)

{:ok, blueprint} = Processor.fetch_blueprint(workspace, blueprint.id)
