defmodule VacEngineWeb.Header.MenuComponent do
  use VacEngineWeb, :component

  import VacEngineWeb.IconComponent

  alias VacEngine.Repo

  def menu(assigns) do
    ~H"""
    <div
      id ="account-dropdown"
      class="absolute top-full left-0 bg-blue-800 z-50 hidden text-white text-sm px-2 pt-2 pb-1">
      <.session_info role={@role} workspace={@workspace} />
      <div class="h-1"/>
      <%= for attrs <- menu_entries(assigns) do %>
        <.menu_entry {attrs} />
      <% end %>
    </div>
    """
  end

  defp session_info(%{workspace: nil} = assigns) do
    role = assigns.role |> Repo.preload(:user)
    assigns = assign(assigns, role: role)

    ~H"""
    <div class="grid grid-cols-1 border text-xs border-blue-600 p-2">
    <div class="font-bold text-blue-200">User:</div>
    <div class="italic"><%= @role.user.name %></div>
    <div class="italic"><%= @role.user.email %></div>
    <div class="font-bold text-blue-200 pt-2">Workspace:</div>
    <div class="italic">no workspace</div>
    </div>

    """
  end

  defp session_info(%{workspace: _workspace} = assigns) do
    role = assigns.role |> Repo.preload(:user)
    assigns = assign(assigns, role: role)

    ~H"""
    <div class="grid grid-cols-1 border text-xs border-blue-600 p-2">
    <div class="font-bold text-blue-200">User:</div>
    <div class="italic"><%= @role.user.name %></div>
    <div class="italic"><%= @role.user.email %></div>
    <div class="font-bold text-blue-200 pt-2">Workspace:</div>
    <div class="italic"><%= @workspace.name %></div>
    </div>
    """
  end

  defp menu_entry(assigns) do
    l =
      if assigns.i do
        ~H"""
        <.icon name={assigns.i} width="1.5rem" class="inline" />
        <div class="inline-block pl-1"><%= @l %></div>
        """
      else
        assigns.l
      end

    assigns = assign(assigns, l: l)

    ~H"""
    <%= live_patch @l,
    to: @a,
    class: "flex items-center
    my-1 pl-2 pr-3 py-2
    rounded-sm border
    font-bold
    bg-blue-600 hover:bg-blue-700 border-blue-500"
    %>
    """
  end

  defp menu_entries(%{role: role} = _assigns) do
    default_menu = [
      %{
        l: "Change workspace",
        a: Routes.nav_path(Endpoint, :index),
        i: "hero/switch-horizontal"
      },
      %{
        l: "Logout",
        a: Routes.logout_path(Endpoint, :logout),
        i: "hero/logout"
      }
    ]

    admin_menu(role) ++ default_menu
  end

  defp menu_entries(_) do
    []
  end

  defp admin_menu(%{global_permission: %{super_admin: true}}) do
    [
      %{
        l: "Admin settings",
        a: Routes.user_path(Endpoint, :index),
        i: "hero/cog"
      }
    ]
  end

  defp admin_menu(_) do
    []
  end
end
