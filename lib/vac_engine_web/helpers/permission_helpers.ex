defmodule VacEngineWeb.PermissionHelpers do
  alias VacEngine.Account.Role
  alias VacEngine.Account.User
  alias VacEngine.Account.Session
  alias VacEngine.Account

  def can?(target, action) do
    can?(target, action, :global)
  end

  def can?(%Role{} = role, action, scope) do
    Account.can?(role, action, scope)
  end

  def can?(
        %Plug.Conn{assigns: %{role_session: %{role: role}}} = _socket,
        action,
        scope
      ) do
    can?(role, action, scope)
  end

  def can?(
        %Plug.Conn{assigns: %{role: role}} = _socket,
        action,
        scope
      ) do
    can?(role, action, scope)
  end

  def can?(
        %Phoenix.LiveView.Socket{assigns: %{role_session: %{role: role}}} =
          _socket,
        action,
        scope
      ) do
    can?(role, action, scope)
  end

  def can?(
        %Phoenix.LiveView.Socket{assigns: %{role: role}} = _socket,
        action,
        scope
      ) do
    can?(role, action, scope)
  end

  def can?(%Session{role: role}, action, scope) do
    can?(role, action, scope)
  end

  def can?(_val, _name, _key), do: false
  false

  def has?(target, action) do
    has?(target, action, :global)
  end

  def has?(%Role{} = role, action, scope) do
    Account.has?(role, action, scope)
  end

  def has?(
        %Plug.Conn{assigns: %{role_session: %{role: role}}} = _socket,
        action,
        scope
      ) do
    has?(role, action, scope)
  end

  def has?(
        %Plug.Conn{assigns: %{role: role}} = _socket,
        action,
        scope
      ) do
    has?(role, action, scope)
  end

  def has?(
        %Phoenix.LiveView.Socket{assigns: %{role_session: %{role: role}}} =
          _socket,
        action,
        scope
      ) do
    has?(role, action, scope)
  end

  def has?(
        %Phoenix.LiveView.Socket{assigns: %{role: role}} = _socket,
        action,
        scope
      ) do
    has?(role, action, scope)
  end

  def has?(%Session{role: role}, action, scope) do
    has?(role, action, scope)
  end

  def has?(_val, _name, _key), do: false

  def myself?(a, b) do
    role_id(a) == role_id(b)
  end

  def can!(val, action) do
    can!(val, action, :global)
  end

  def can!(val, action, scope) do
    unless can?(val, action, scope) do
      denied!()
    end
  end

  def not_myself!(a, b) do
    if myself?(a, b) do
      denied!()
    end
  end

  def myself!(a, b) do
    unless myself?(a, b) do
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
