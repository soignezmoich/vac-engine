defmodule VacEngineWeb.HeaderComponent do
  use VacEngineWeb, :component
  alias VacEngineWeb.UserLive
  alias VacEngineWeb.Endpoint
  alias VacEngineWeb.WorkspaceLive
  import Routes

  def header(assigns) do
    ~H"""
    <header
      class="flex font-bold bg-gray-50 flex-shrink-0
             flex-grow-0 shadow-sm z-10">
      <nav class="px-1 flex flex-grow">
        <%= for el <- header_els(:left, @role) do %>
          <%= el %>
        <% end %>
        <div class="flex-grow"></div>
        <%= for el <- header_els(:right, @role) do %>
          <%= el %>
        <% end %>
      </nav>
    </header>
    """
  end

  defp lnk(label, href) do
    assigns = %{label: label, href: href}

    ~H"""
    <div class="flex">
      <%= live_redirect to: @href,
            class: "px-4 py-1 flex-grow hover:bg-blue-600 hover:text-gray-100" do %>
        <%= @label %>
      <% end %>
    </div>
    """
  end

  defp admin_menu(role) do
    assigns = %{role: role}

    ~H"""
    <div class="relative flex">
      <div class="flex px-4 py-1 cursor-default
                  hover:bg-blue-600 hover:text-gray-100"
           id="admin-menu"
           phx_update="ignore"
           data-dropdown="admin-menu-content">
        Admin
      </div>
      <div class="hidden absolute bg-cream-200 flex
                  items-stretch flex-col top-full" id="admin-menu-content">
        <%= for el <- header_els(:admin, @role) do %>
          <%= el %>
        <% end %>
      </div>
    </div>
    """
  end

  defp header_els(:left, role)
       when not is_nil(role) do
    [
      # {"Dashboard", Routes.dashboard_path(Endpoint, :index), true},
      # {"Users", Routes.live_path(Endpoint, UserLive.Index),
      # can?(role, :admin_users)},
      # {"Workspaces", Routes.live_path(Endpoint, WorkspaceLive.Index),
      # can?(role, :admin_workspaces)}
    ]
    |> filter_keep()
  end

  defp header_els(:admin, role)
       when not is_nil(role) do
    [
      {lnk("Users", live_path(Endpoint, UserLive.Index)),
       can?(role, :admin_users)},
      {lnk("Workspaces", live_path(Endpoint, WorkspaceLive.Index)),
       can?(role, :admin_workspaces)}
    ]
    |> filter_keep()
  end

  defp header_els(:right, role)
       when not is_nil(role) do
    [
      {admin_menu(role), can?(role, :admin)},
      lnk("Logout", auth_path(Endpoint, :logout))
    ]
    |> filter_keep()
  end

  defp header_els(:left, _) do
    []
  end

  defp header_els(:right, _) do
    [
      lnk("Login", auth_login_path(Endpoint, :login))
    ]
  end

  defp header_els(_, _) do
    []
  end

  defp filter_keep(list) do
    list
    |> Enum.filter(fn
      {_, keep} -> keep
      _v -> true
    end)
    |> Enum.map(fn
      {v, _} -> v
      v -> v
    end)
  end
end
