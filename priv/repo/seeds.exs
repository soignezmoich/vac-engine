alias VacEngine.Account
alias VacEngine.Processor
alias VacEngine.Processor.Blueprint
alias Fixtures.Blueprints

blueprint = Blueprints.blueprints() |> Map.get(:ruleset0)

VacEngine.Repo.transaction(fn ->
  {:ok, user} =
    Account.create_user(%{
      "name" => "Default Admin",
      "email" => "admin@admin.com",
      "password" => "12341234"
    })

  {:ok, _role} = Account.grant_permission(user.role, [:global, :users, :write])

  {:ok, _role} =
    Account.grant_permission(user.role, [:global, :workspaces, :write])

  {:ok, workspace} = Account.create_workspace(%{name: "Test workspace"})

  {:ok, blueprint} =
    Processor.create_blueprint(
      workspace,
      blueprint
    )
end)
