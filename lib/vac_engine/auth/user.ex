defmodule VacEngine.Auth.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias VacEngine.Auth.Role

  schema "users" do
    timestamps(type: :utc_datetime)

    field(:name, :string)
    field(:description, :string)
    field(:email, :string)
    field(:phone, :string)
    field(:encrypted_password, :string)
    field(:totp_secret, :string)

    belongs_to(:role, Role)

    field(:password, :string, virtual: true)
    field(:last_login_at, :utc_datetime, virtual: true)
    field(:last_active_at, :utc_datetime, virtual: true)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :description, :phone, :password, :email])
    |> encrypt_password()
    |> validate_required([:name, :encrypted_password, :email])
    |> validate_length(:password, min: 8, max: 1024)
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/.+@.+\..+/)
  end

  @doc """
  Encrypt the password in `changeset` and return a new changeset with
  `encrypted_password` set as changes
  """
  def encrypt_password(%{changes: %{password: pass}} = changeset) do
    pass = Argon2.hash_pwd_salt(pass)

    changeset
    |> put_change(:encrypted_password, pass)
    |> put_change(:password, nil)
  end

  def encrypt_password(changeset) do
    changeset
  end

  def check_password(nil, _password) do
    Argon2.no_user_verify()
  end

  def check_password(_user, nil) do
    Argon2.no_user_verify()
  end

  def check_password(_user, password) when byte_size(password) > 1024, do: false

  def check_password(user, password) do
    Argon2.verify_pass(password, user.encrypted_password)
  end
end
