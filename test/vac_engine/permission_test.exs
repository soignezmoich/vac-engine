defmodule VacEngine.PermissionTest do
  use VacEngine.DataCase

  alias VacEngine.Account
  alias VacEngine.Processor
  alias VacEngine.Pub
  alias VacEngine.Query

  setup do
    {:ok, super_admin} =
      Account.create_user(%{
        email: "super@admin.com",
        name: "Test admin",
        password: Account.generate_secret(8)
      })

    super_admin = grant(super_admin.role, :super_admin)

    {:ok, user1} =
      Account.create_user(%{
        email: "user1@admin.com",
        name: "User 1",
        password: Account.generate_secret(8)
      })

    workspaces =
      Enum.map(0..9, fn n ->
        {:ok, workspace} =
          Account.create_workspace(%{name: "Test workspace #{n}"})

        workspace
      end)

    [ws, ws1, ws2 | _] = workspaces

    {:ok, br} = Processor.create_blueprint(ws, %{name: "Test blueprint 1"})
    {:ok, br1} = Processor.create_blueprint(ws, %{name: "Test blueprint 2"})
    {:ok, br2} = Processor.create_blueprint(ws1, %{name: "Test blueprint 3"})
    {:ok, br3} = Processor.create_blueprint(ws2, %{name: "Test blueprint 4"})
    {:ok, pub} = Pub.publish_blueprint(br, %{name: "Test portal 1"})
    {:ok, pub1} = Pub.publish_blueprint(br1, %{name: "Test portal 2"})
    {:ok, pub2} = Pub.publish_blueprint(br2, %{name: "Test portal 3"})
    {:ok, pub3} = Pub.publish_blueprint(br3, %{name: "Test portal 4"})

    [
      workspaces: workspaces,
      super_admin: super_admin,
      user1: user1.role,
      blueprint: br,
      blueprints: [br, br1, br2, br3],
      portals: [pub.portal, pub1.portal, pub2.portal, pub3.portal],
      portal: pub.portal
    ]
  end

  test "accessible workspaces for user", %{
    super_admin: super_admin,
    user1: user1,
    workspaces: workspaces,
    blueprint: blueprint,
    portal: portal
  } do
    super_admin_workspaces = get_ws(super_admin)

    assert super_admin_workspaces == workspaces
    assert Enum.count(super_admin_workspaces) == 10

    user1_workspaces = get_ws(user1)

    assert user1_workspaces == []
    assert Enum.empty?(user1_workspaces)

    [ws | _] = workspaces

    user1 = grant(user1, :read_portals, ws)
    assert get_ws(user1) == [ws]
    user1 = revoke(user1, :read_portals, ws)
    assert get_ws(user1) == [ws]
    user1 = delete(user1, ws)
    assert get_ws(user1) == []
    user1 = grant(user1, :run, portal)
    assert get_ws(user1) == [ws]
    user1 = revoke(user1, :run, portal)
    assert get_ws(user1) == [ws]
    user1 = delete(user1, portal)
    assert get_ws(user1) == []
    user1 = grant(user1, :write, blueprint)
    assert get_ws(user1) == [ws]
    user1 = revoke(user1, :write, blueprint)
    assert get_ws(user1) == [ws]
    user1 = delete(user1, blueprint)
    assert get_ws(user1) == []

    super_admin = revoke(super_admin, :super_admin)
    assert get_ws(super_admin) == []
  end

  test "grant all permissions", %{
    user1: user1,
    workspaces: workspaces,
    blueprint: blueprint,
    portal: portal
  } do
    [ws, ws2 | _] = workspaces

    assert get_ws(user1) == []
    user1 = grant(user1, :read, blueprint)
    user1 = grant(user1, :write, blueprint)
    user1 = grant(user1, :read, portal)
    user1 = grant(user1, :write, portal)
    user1 = grant(user1, :run, portal)
    assert get_ws(user1) == [ws]
    user1 = grant(user1, :read_portals, ws)
    user1 = grant(user1, :write_portals, ws)
    user1 = grant(user1, :run_portals, ws)
    user1 = grant(user1, :write_blueprints, ws)
    user1 = grant(user1, :read_blueprints, ws)
    assert get_ws(user1) == [ws]
    user1 = delete(user1, ws)
    assert get_ws(user1) == [ws]
    user1 = delete(user1, blueprint)
    assert get_ws(user1) == [ws]
    user1 = delete(user1, portal)
    assert get_ws(user1) == []
    user1 = grant(user1, :read_blueprints, ws2)
    assert get_ws(user1) == [ws2]
  end

  test "per blueprint permissions", %{
    user1: user1,
    workspaces: workspaces,
    blueprints: blueprints
  } do
    [ws | _] = workspaces
    [br, br1 | _] = blueprints
    assert get_ws(user1) == []
    assert get_bs(user1, ws) == []
    user1 = grant(user1, :read_blueprints, ws)
    assert get_bs(user1, ws) == [br, br1]
    user1 = grant(user1, :read, br)
    assert get_bs(user1, ws) == [br, br1]
    user1 = revoke(user1, :read_blueprints, ws)
    assert get_bs(user1, ws) == [br]
  end

  defp grant(role, action, scope \\ :global) do
    {:ok, _perm} = Account.grant_permission(role, action, scope)

    Account.get_role!(role.id, fn q ->
      q
      |> Account.load_role_permissions()
    end)
  end

  defp revoke(role, action, scope \\ :global) do
    {:ok, _perm} = Account.revoke_permission(role, action, scope)

    Account.get_role!(role.id, fn q ->
      q
      |> Account.load_role_permissions()
    end)
  end

  defp delete(role, scope) do
    {:ok, _perm} = Account.delete_permissions(role, scope)

    Account.get_role!(role.id, fn q ->
      q
      |> Account.load_role_permissions()
    end)
  end

  defp get_ws(role) do
    Account.list_workspaces(fn q ->
      Account.filter_accessible_workspaces(q, role)
    end)
  end

  defp get_bs(role, ws) do
    Processor.list_blueprints(fn q ->
      q
      |> Processor.filter_blueprints_by_workspace(ws)
      |> Processor.filter_accessible_blueprints(role)
      |> Query.order_by(:id)
    end)
  end
end
