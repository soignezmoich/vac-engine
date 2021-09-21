defmodule VacEngineWeb.PermissionHelpers do
  alias VacEngine.Auth.Role
  alias VacEngine.Auth.Session

  def can?(%Role{} = role, name, key) do
    VacEngine.Permissions.can?(role, name, key)
  end

  def can?(
        %Phoenix.LiveView.Socket{assigns: %{role_session: %{role: role}}} =
          socket,
        name,
        key
      ) do
    can?(role, name, key)
  end

  def can?(%Session{role: role}, name, key) do
    can?(role, name, key)
  end

  def can?(_val, _name, _key), do: false

  def can!(val, name, key) do
    unless can?(val, name, key) do
      raise VacEngineWeb.PermissionError
    end
  end
end


defmodule VacEngineWeb.PermissionError do
  defexception message: "unauthorized", plug_status: 403
end
