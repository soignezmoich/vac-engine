defmodule VacEngine.Account.Users do
  @moduledoc false

  import Ecto.Query
  alias Ecto.Multi
  alias Ecto.Changeset
  alias VacEngine.Repo
  alias VacEngine.Account.User
  alias VacEngine.Account.Session
  alias VacEngine.Account.Roles

  def list_users(queries) do
    User
    |> queries.()
    |> Repo.all()
  end

  def get_user!(id, queries) do
    User
    |> queries.()
    |> Repo.get!(id)
  end

  def load_user_activity(query) do
    session_query =
      from(s in Session,
        order_by: [desc: s.inserted_at],
        where: s.role_id == parent_as(:users).role_id,
        limit: 1
      )

    from(u in query,
      as: :users,
      left_lateral_join: s in subquery(session_query),
      join: r in assoc(u, :role),
      order_by: u.id,
      preload: [role: r],
      select: %{
        u
        | last_login_at: s.inserted_at,
          last_active_at: s.last_active_at,
          active: r.active
      }
    )
  end

  def load_user_role(query) do
    from(u in query,
      preload: :role
    )
  end

  def check_password(nil, _password) do
    Argon2.no_user_verify()
  end

  def check_password(_user, nil) do
    Argon2.no_user_verify()
  end

  def check_password(_user, password) when byte_size(password) > 1024, do: false

  def check_password(%User{} = user, password) do
    Argon2.verify_pass(password, user.encrypted_password)
  end

  def check_user(email, password) do
    with user <-
           from(u in User,
             join: r in assoc(u, :role),
             where: u.email == ^email and r.active == true
           )
           |> Repo.one(),
         true <- check_password(user, password) do
      {:ok, user}
    else
      _ ->
        {:error, "invalid email or password"}
    end
  end

  def create_user(attrs) do
    Multi.new()
    |> Multi.run(:validate, fn _, _ ->
      %User{}
      |> User.changeset(attrs)
      |> Changeset.apply_action(:insert)
    end)
    |> Multi.append(Roles.create_role_multi(:user))
    |> Multi.insert(:user, fn %{role: role} ->
      %User{role_id: role.id}
      |> User.changeset(attrs)
    end)
    |> Multi.update(:role_user, fn %{role: role, user: user} ->
      Ecto.Changeset.change(role, user_id: user.id)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user, role: role}} -> {:ok, %{user | role: role}}
      {:error, _, err, _} -> {:error, err}
    end
  end

  def change_user(data, attrs \\ %{}) do
    User.changeset(data, attrs)
  end

  def update_user(data, attrs \\ %{}) do
    User.changeset(data, attrs)
    |> Repo.update()
  end

  def gen_totp(user) do
    secret = NimbleTOTP.secret()

    url =
      NimbleTOTP.otpauth_uri("VacEngine:#{user.email}", secret,
        issuer: "VacEngine"
      )

    {url, secret}
  end
end
