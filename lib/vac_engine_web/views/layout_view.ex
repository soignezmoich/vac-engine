defmodule VacEngineWeb.LayoutView do
  use VacEngineWeb, :view
  alias VacEngineWeb.UserLive
  alias VacEngineWeb.WorkspaceLive

  def header_els(:left, %{assigns: %{role: role}} = conn)
      when not is_nil(role) do
    [
      {"Dashboard", Routes.dashboard_path(conn, :index), true},
      {"Users", Routes.live_path(conn, UserLive.Index),
       can?(role, :users, :read)},
      {"Workspaces", Routes.live_path(conn, WorkspaceLive.Index),
       can?(role, :workspaces, :read)}
    ]
    |> Enum.filter(fn {_, _, keep} -> keep end)
    |> Enum.map(fn {a, b, _} -> {a, b} end)
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
