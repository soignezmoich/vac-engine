defmodule VacEngineWeb.PermissionHelpers do
  alias VacEngine.Accounts.Role
  alias VacEngine.Accounts.User
  alias VacEngine.Accounts.Session
  alias VacEngine.Accounts

  def can?(%Role{} = role, name, key) do
    Accounts.has_permission?(role, [:global, name, key])
  end

  def can?(
        %Phoenix.LiveView.Socket{assigns: %{role_session: %{role: role}}} =
          _socket,
        name,
        key
      ) do
    can?(role, name, key)
  end

  def can?(%Session{role: role}, name, key) do
    Accounts.has_permission?(role, [:global, name, key])
  end

  def can?(_val, _name, _key), do: false

  def self?(a, b) do
    role_id(a) == role_id(b)
  end

  def can!(val, name, key) do
    unless can?(val, name, key) do
      denied!()
    end
  end

  def not_self!(a, b) do
    if self?(a, b) do
      denied!()
    end
  end

  def check!(false), do: denied!()
  def check!(true), do: nil

  def denied!() do
    raise VacEngineWeb.PermissionError
  end

  defp role_id(%User{role_id: id}), do: id
  defp role_id(%Role{id: id}), do: id
  defp role_id(%Session{role_id: id}), do: id

  defp role_id(%Phoenix.LiveView.Socket{assigns: %{role_session: session}}) do
    role_id(session)
  end

  defp role_id(_), do: denied!()
end

defmodule VacEngineWeb.PermissionError do
  defexception message: "unauthorized", plug_status: 403
end
