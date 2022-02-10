defmodule VacEngineWeb.HeaderComponent do
  use VacEngineWeb, :component

  import Routes
  import VacEngineWeb.Header.SubElementComponent
  import VacEngineWeb.Header.TitleComponent
  import VacEngineWeb.Header.TopElementComponent
  import VacEngineWeb.IconComponent
  import VacEngineWeb.VersionHelpers

  alias VacEngine.Repo
  alias VacEngineWeb.Endpoint

  def header(assigns) do

    ~H"""
    <header class="flex flex-col lg:flex-row relative bg-blue-700">
      <nav class="flex mx-2  xl:self-stretch
                  items-stretch h-14">
        <.account_element
          role={@role}
          workspace={@workspace}
          workspaces={@workspaces} />

        <%= for attrs <- top_elements(assigns) do %>
          <.top_element {attrs} />
        <% end %>

        <div class="flex whitespace-nowrap pl-4 pr-1 font-bold items-center justify-center text-xl text-white italic truncate">
          <.title {assigns} />
        </div>
      </nav>


      <%= if length(sub_elements(assigns)) > 0 do %>
        <div class="hidden lg:flex flex-grow">
        </div>
        <div class="text-cream-50 hidden lg:flex">
          <svg width={"3.5rem"}
            height={"3.5rem"}
            viewBox="0 0 200 200">
            <use href={"/slope.svg#slope"}></use>
          </svg>
        </div>
        <nav class="flex bg-cream-50 min-w-full lg:min-w-fit px-2">
          <%= for attrs <- sub_elements(assigns) do %>
            <.sub_element {attrs} />
          <% end %>
        </nav>
      <% else %>
      <div class="hidden lg:flex flex-grow bg-blue-700 h-14">
        <div class="absolute top-0 right-0 py-1 px-3 text-xs text-gray-200">
          Version: <%= version() %>.
          Build date: <%= build_date() %>.
        </div>
      </div>
    <% end %>
    </header>
    """
  end



  defp blueprints_element(%{role: nil} = assigns) do
    ~H""
  end

  defp blueprints_element(%{workspace: nil} = assigns) do
    ~H""
  end

  defp blueprints_element(%{role: _role} = assigns) do

    content = ~H"""
    <.icon name="hero/view-list" width="1.5rem" class="inline" />
    <div class="pl-1">Blueprints</div>
    """

    ~H"""
    <%= live_patch content,
    to: Routes.workspace_blueprint_path(Endpoint, :index, @workspace.id),
    class: "flex
    my-1 mx-1 pl-2 pr-4 py-2
    items-center
    border rounded-sm
    shadow-md
    text-gray-50 bg-blue-800 hover:bg-blue-700 border-blue-500
    font-bold" %>
    """
  end

  defp portals_element(%{role: nil} = assigns) do
    ~H""
  end

  defp portals_element(%{workspace: nil} = assigns) do
    ~H""
  end

  defp portals_element(%{role: _role} = assigns) do

    content = ~H"""
    <.icon name="hero/switch-vertical" width="1.5rem" class="inline" />
    <div class="pl-1">Portals</div>
    """

    ~H"""
    <%= live_patch content,
    to: Routes.workspace_portal_path(Endpoint, :index, @workspace),
    class: "flex
    m-1 px-4 py-2
    items-center
    border rounded-sm
    shadow-md
    text-gray-50 bg-blue-800 hover:bg-blue-700 border-blue-500
    font-bold" %>
    """
  end

  defp account_element(%{role: nil} = assigns) do

    attrs = %{
      l: "Login",
      a: Routes.login_path(Endpoint, :form),
      s: false,
      i: "hero/login"
    }

    assigns = assign(assigns, attrs: attrs)

    ~H"""
    <.top_element {@attrs} />
    """
    # ~H"""
    # <div class={
    #       "px-2 font-bold text-gray-50 font-lg italic flex
    #        items-stretch border border-blue-500"}>
    #   <%= live_patch "Login", to: login_path(Endpoint, :form), class: "items-center flex" %>
    # </div>
    # """
  end

  defp account_element(%{role: role} = assigns) do
    ~H"""
    <div class="relative font-normal flex w-12 h-12 shadow-md item-center justify-center
      text-sm mx-1 my-1 px-2 pt-1.5 text-gray-50 rounded-full
      cursor-pointer bg-blue-800 hover:bg-blue-700 border border-blue-500 pt-0.5"
      id="account-dropdown-menu"
      data-dropdown="account-dropdown"
      >
      <.icon name="hero/user" width="2rem" />
    </div>
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

    l = if assigns.i do
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
    bg-blue-700 hover:bg-blue-600 border-blue-500"
    %>
    """
  end





  defp menu_entries(%{role: role} = _assigns) do
    default_menu = [
      %{
        l: "Change workspace",
        a:  nav_path(Endpoint, :index),
        i: "hero/switch-horizontal",
      },
      %{
        l: "Logout",
        a: logout_path(Endpoint, :logout),
        i: "hero/logout",
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
        l: "Admin",
        a: user_path(Endpoint, :index),
        i: "hero/cog",
      },
    ]
  end

  defp admin_menu(_) do
    []
  end

  defp at([a | _], a), do: true
  defp at(_, _), do: false
  # defp at([a, b | _], a, b), do: true
  # defp at(_, _, _), do: false
end
