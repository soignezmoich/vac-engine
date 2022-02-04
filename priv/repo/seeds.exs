alias VacEngine.Pub
alias VacEngine.Account
alias VacEngine.Processor

VacEngine.Repo.query("delete from publications;")
VacEngine.Repo.query("delete from blueprints;")
VacEngine.Repo.query("delete from roles;")
VacEngine.Repo.query("delete from portals;")

{:ok, user} =
  VacEngine.Repo.transaction(fn ->
    email = "admin@admin.local"
    pass = Account.generate_secret(8) |> String.downcase() |> String.slice(0..8)

    {:ok, user} =
      Account.create_user(%{
        "name" => "Default Admin",
        "email" => email,
        "password" => pass
      })

    {:ok, _perm} = Account.grant_permission(user.role, :super_admin)

    {:ok, role} = Account.create_role(:api)
    {:ok, _perm} = Account.grant_permission(role, :super_admin)
    {:ok, api_token} = Account.create_api_token(role)

    IO.puts("###########################")
    IO.puts("Created admin account with email/password: #{email} / #{pass}")
    IO.puts("Created api key: #{api_token.secret}")

    user
  end)
