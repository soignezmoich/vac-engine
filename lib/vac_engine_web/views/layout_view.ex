defmodule VacEngineWeb.LayoutView do
  use VacEngineWeb, :view
  alias VacEngineWeb.UserLive

  def header_els(:left, %{assigns: %{role: role}} = conn)
      when not is_nil(role) do
    [
      {"Dashboard", Routes.dashboard_path(conn, :index)}
    ] ++
      if can?(role, :users, :read) do
        [
          {"Users", Routes.live_path(conn, UserLive.Index)}
        ]
      else
        []
      end
  end

  def header_els(:right, %{assigns: %{role: role}} = conn)
      when not is_nil(role) do
    [
      {"Logout", Routes.auth_path(conn, :logout)}
    ]
  end

  def header_els(:left, _conn) do
    []
  end

  def header_els(:right, conn) do
    [
      {"Login", Routes.auth_login_path(conn, :login)}
    ]
  end
end
