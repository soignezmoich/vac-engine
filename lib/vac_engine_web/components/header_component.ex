defmodule VacEngineWeb.HeaderComponent do
  use VacEngineWeb, :component
  alias VacEngineWeb.Endpoint
  import Routes

  def header(assigns) do
    ~H"""
    <header
      class="flex font-bold bg-blue-700 flex-shrink-0 flex-col text-gray-100
             flex-grow-0 shadow-md z-10">
      <nav class="flex flex-grow">
        <%= if @workspace do %>
          <.workspaces_menu workspace={@workspace} workspaces={@workspaces}
                sel={at(@location, :workspace)} />
        <% else %>
          <.lnk label="Workspace" href={nav_path(Endpoint, :index)}
                sel={at(@location, :workspace)} />
        <% end %>
        <div class="flex-grow"></div>
        <%= if @workspace do %>
          <.lnk label="Editor"
                href={workspace_blueprint_path(Endpoint, :index, @workspace.id)}
                sel={at(@location, :blueprint)} />
        <% end %>
        <%= if can?(@role, :manage, :users) do %>
          <.lnk label="Admin"
                href={user_path(Endpoint, :index)}
                sel={at(@location, :admin)} />
        <% end %>
        <%= if @role do %>
          <.lnk label="Logout" href={logout_path(Endpoint, :logout)} />
        <% else %>
          <.lnk label="Login" href={login_path(Endpoint, :form)} />
        <% end %>
      </nav>
      <nav class="bg-cream-300 text-cream-900 flex">
        <%= if at(@location, :admin) do %>
          <div class="flex-grow"></div>
          <div>
            <.lnk label="Users" href={user_path(Endpoint, :index)}
                  sel={at(@location, :admin, :user)} />
          </div>
          <div>
            <.lnk label="Workspaces" href={workspace_path(Endpoint, :index)}
                  sel={at(@location, :admin, :workspace)} />
          </div>
        <% end %>
        <%= if @workspace && at(@location, :workspace) do %>
          <div>
            <.lnk label="Blueprints" href={workspace_blueprint_path(Endpoint, :index, @workspace.id)}
                  sel={at(@location, :workspace, :blueprint)} />
          </div>
        <% end %>
        <%= if at(@location, :blueprint) do %>
          <div phx-click="save"
               class="px-4 py-1 cursor-default hover:bg-blue-900 hover:text-gray-200">
            Save
          </div>
        <% end %>
      </nav>
    </header>
    """
  end

  defp lnk(assigns) do
    assigns =
      assigns
      |> Map.get(:sel)
      |> case do
        true -> assign(assigns, sel: "bg-blue-600 text-gray-100")
        _ -> assign(assigns, sel: "")
      end

    ~H"""
    <div class="flex flex-shrink-0">
      <%= live_redirect to: @href,
          class: "px-4 py-1 flex-grow hover:bg-blue-900 hover:text-gray-200
                  flex-shrink-0 #{@sel}" do %>
        <%= @label %>
      <% end %>
    </div>
    """
  end

  defp at([a | _], a), do: true
  defp at(_, _), do: false
  defp at([a, b | _], a, b), do: true
  defp at(_, _, _), do: false
  # defp at([a, b, c | _], a, b, c), do: true
  # defp at(_, _, _, _), do: false

  defp workspaces_menu(assigns) do
    assigns =
      if length(assigns.workspaces) > 10 do
        assign(assigns,
          truncated: true,
          workspaces: Enum.take(assigns.workspaces, 10)
        )
      else
        assign(assigns, truncated: false)
      end

    assigns =
      assigns
      |> Map.get(:sel)
      |> case do
        true -> assign(assigns, sel: "bg-blue-600 text-gray-100")
        _ -> assign(assigns, sel: "")
      end

    ~H"""
    <div class="relative flex">
      <div class={"flex px-4 py-1 cursor-default
                  hover:bg-blue-900 hover:text-gray-200 #{@sel}"}
           id="workspaces-menu"
           phx_update="ignore"
           data-dropdown="workspaces-menu-content">
          <%= tr(@workspace.name, 32) %>
      </div>
      <div class="hidden absolute bg-blue-600 flex flex-col
                  top-full left-0 min-w-max" id="workspaces-menu-content">
        <%= for w <- @workspaces do %>
          <.lnk href={workspace_dashboard_path(Endpoint, :index, w.id)}
            label={tr(w.name, 32)} />
        <% end %>
        <%= if @truncated do %>
        <div class="px-4 py-2 font-normal text-sm max-w-xs">
          Workspaces list was truncated,
          you have access to more workspaces.
        </div>
        <.lnk href={nav_path(Endpoint, :index)} label="Full list" />
        <% end %>
      </div>
    </div>
    """
  end
end
