alias VacEngine.Pub
alias VacEngine.Account
alias VacEngine.Processor
alias Fixtures.Blueprints

VacEngine.Repo.query("delete from publications;")
VacEngine.Repo.query("delete from blueprints;")
VacEngine.Repo.query("delete from roles;")

blueprint = Blueprints.blueprints() |> Map.get(:ruleset0)

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

    {:ok, _role} =
      Account.grant_permission(user.role, [:global, :users, :write])

    {:ok, _role} =
      Account.grant_permission(user.role, [:global, :workspaces, :write])

    {:ok, workspace} = Account.create_workspace(%{name: "Test workspace"})

    {:ok, blueprint} =
      Processor.create_blueprint(
        workspace,
        blueprint
      )

    {:ok, _publication} = Pub.publish_blueprint(blueprint)

    {:ok, role} = Account.create_role(:api)
    {:ok, role} = Account.grant_permission(role, [:global, :users, :read])
    {:ok, role} = Account.grant_permission(role, [:global, :workspaces, :read])
    {:ok, api_token} = Account.create_api_token(role)

    IO.puts("###########################")
    IO.puts("Created admin account with email/password: #{email} / #{pass}")
    IO.puts("Created api key: #{api_token.secret}")

    {workspace, blueprint}
  end)

{:ok, blueprint} = Processor.fetch_blueprint(workspace, blueprint.id)
