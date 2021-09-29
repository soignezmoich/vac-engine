alias VacEngine.Accounts
alias VacEngine.Processor
alias VacEngine.Blueprints
alias VacEngine.Blueprints.Blueprint

VacEngine.Repo.transaction(fn ->
  {:ok, user} =
    Accounts.create_user(%{
      "name" => "Default Admin",
      "email" => "admin@admin.com",
      "password" => "12341234"
    })
    |> IO.inspect()

  {:ok, _role} = Accounts.grant_permission(user.role, [:global, :users, :write])

  {:ok, _role} =
    Accounts.grant_permission(user.role, [:global, :workspaces, :write])

  blueprint = %{
    name: :test,
    variables: %{
      aint: %{type: :integer, input: true, output: false, default: 0},
      bint: %{type: :integer, input: true, output: false, default: 0}
    },
    deductions: [
      %{
        branches: [
          %{
            conditions: [
              %{expression: quote(do: gt(@aint, 75))},
              %{expression: quote(do: lt(@aint, 200))}
            ],
            assignements: [
              %{target: :aint, expression: quote(do: add(1, @aint))},
              %{target: :cint, expression: quote(do: add(2, @bint))}
            ]
          }
        ]
      },
      %{
        branches: [
          %{
            conditions: [
              %{expression: quote(do: gt(@aint, 200))}
            ],
            assignements: [
              %{target: :aint, expression: quote(do: add(@aint, 1))}
            ]
          }
        ]
      }
    ]
  }

  {:ok, workspace} = Accounts.create_workspace(%{name: "Test workspace"})

  {:ok, blueprint} =
    Blueprints.create_blueprint(
      workspace,
      blueprint
    )

end)

