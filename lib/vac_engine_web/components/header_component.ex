defmodule VacEngineWeb.HeaderComponent do
  use VacEngineWeb, :component
  alias VacEngineWeb.Endpoint
  import Routes

  def header(assigns) do
    ~H"""
    <header
      class="flex font-bold bg-blue-700 flex-shrink-0 flex-col text-gray-100
             flex-grow-0 shadow-md z-10">

      <!-- MAIN MENU -->

      <nav class="flex flex-grow">
        <div>
          <div class="h-10"/>
          <div class="h-5 w-2"/>
        </div>

         <!-- Admin tab -->

        <%= if can?(@role, :manage, :users) do %>
          <.lnk label="Admin"
                href={user_path(Endpoint, :index)}
                style="main-menu"
                sel={at(@location, :admin)} />
        <% end %>

        <div class="w-4"/>

        <!-- Workspace tab + selector -->

        <%= if @workspace do %>
          <.lnk label="Workspace"
                href={workspace_dashboard_path(Endpoint, :index, @workspace.id)}
                subtitle={"<#{@workspace.name}>"}
                style="main-menu"
                sel={at(@location, :workspace)} />
        <% else %>
          <.lnk label="Workspace"
                href={nav_path(Endpoint, :index)}
                style="main-menu"
                sel={at(@location, :workspace)} />
        <% end %>

        <%= if Enum.count(@workspaces) > 1 do %>
          <.workspaces_menu workspace={@workspace}
                            workspaces={@workspaces}
                            sel={at(@location, :workspace)} />
        <% end %>

        <div class="w-4"/>

        <!-- Editor tab -->

          <%= if @blueprint do %>
            <.lnk label="Editor"
                  href={workspace_blueprint_path(Endpoint, :index, @workspace.id)}
                  subtitle={"<#{@blueprint.name}>"}
                  style="main-menu"
                  sel={at(@location, :blueprint)} />
          <% else %>
            <%= if @workspace do %>
              <.lnk label="Editor"
                    href={workspace_blueprint_picker_path(Endpoint, :index, @workspace.id)}
                    style="main-menu"
                    sel={at(@location, :blueprint)} />
            <% else %>
              <.disabled_lnk label="Editor"
                    subtitle={"pick workspace first"}
                    style="main-menu" />
            <% end %>
          <% end %>

        <div class="flex-grow"></div>

        <!-- login/logout button -->

        <%= if @role do %>
          <.lnk label="Logout"
                href={logout_path(Endpoint, :logout)} />
        <% else %>
          <.lnk label="Login"
                href={login_path(Endpoint, :form)} />
        <% end %>

        <div class="w-2"/>
      </nav>

      <!-- SUB MENU -->

      <nav class="bg-cream-300 text-cream-900 flex">

        <!-- Admin sub menu -->

        <%= if at(@location, :admin) do %>
          <div>
            <.lnk label="Users"
                  href={user_path(Endpoint, :index)}
                  style="sub-menu"
                  sel={at(@location, :admin, :user)} />
          </div>
          <div>
            <.lnk label="Workspaces"
                  href={workspace_path(Endpoint, :index)}
                  style="sub-menu"
                  sel={at(@location, :admin, :workspace)} />
          </div>
        <% end %>

        <!-- Workspace sub menu -->

          <%= if @workspace && at(@location, :workspace) do %>
          <div>
            <.lnk label="Dashboard"
                  href={workspace_dashboard_path(Endpoint, :index, @workspace.id)}
                  style="sub-menu"
                  sel={at(@location, :workspace, :dashboard)} />
          </div>
          <div>
            <.lnk label="Blueprints"
                  href={workspace_blueprint_path(Endpoint, :index, @workspace.id)}
                  style="sub-menu"
                  sel={at(@location, :workspace, :blueprint)} />
          </div>
        <% end %>

        <!-- Blueprint sub menu -->

        <%= if at(@location, :blueprint) && @location != [:blueprint, :none] do %>
          <div phx-click="save"
               class="px-4 py-1 cursor-default hover:bg-white hover:bg-opacity-30">
            Save
          </div>
        <% end %>
      </nav>
    </header>
    """
  end

  defp disabled_lnk(assigns) do
    assigns =
      assigns
      |> Map.get(:style)
      |> case do
        "main-menu" ->
          assign(assigns,
            style: "border border-grey-400 my-2 px-4 py-1 flex-grow opacity-50"
          )

        "sub-menu" ->
          assign(assigns, style: "flex-grow")

        _ ->
          assign(assigns, style: "")
      end

    ~H"""
    <div class="flex flex-shrink-0">
      <div class={"#{@style}"}>
        <div class="flex items-center h-full text-white">
          <div>
            <div class="px-8 text-center">
              <%= @label %>
            </div>
            <%= case assigns do %>
            <% %{subtitle: subtitle} -> %>
              <div class="text-sm font-light text-center">
                <%= subtitle %>
              </div>
            <% _ -> %>
            <% end %>
          </div>
          <div>
            <div class="h-6"/>
            <div class="h-6"/>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp lnk(assigns) do
    assigns =
      assigns
      |> Map.get(:sel)
      |> case do
        true -> assign(assigns, sel: "bg-opacity-20 bg-white")
        _ -> assign(assigns, sel: "")
      end

    assigns =
      assigns
      |> Map.get(:style)
      |> case do
        "main-menu" ->
          assign(assigns,
            style:
              "shadow-lg border my-2 px-4 py-1 flex-grow hover:bg-white hover:bg-opacity-30"
          )

        "sub-menu" ->
          assign(assigns, style: "flex-grow hover:bg-white hover:bg-opacity-10")

        _ ->
          assign(assigns, style: "")
      end

    ~H"""
    <div class="flex flex-shrink-0">
      <%= live_redirect to: @href,
          class: " #{@sel} #{@style}" do %>

        <div class="flex items-center h-full text-white hover:drop-shadow hover:filter">
          <div>
            <div class="px-8 text-center">
              <%= @label %>
            </div>
            <%= case assigns do %>
            <% %{subtitle: subtitle} -> %>
              <div class="text-sm font-light text-center">
                <%= subtitle %>
              </div>
            <% _ -> %>
            <% end %>
          </div>
          <div>
            <div class="h-6"/>
            <div class="h-6"/>
          </div>
        </div>

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
      |> IO.inspect()
      |> case do
        true -> assign(assigns, sel: "bg-white bg-opacity-20")
        _ -> assign(assigns, sel: "")
      end

    # <%= tr(@workspace.name, 32) %>

    ~H"""
    <div class="relative flex">
      <div class={"flex cursor-default
                  hover:bg-white hover:bg-opacity-30 #{@sel} my-2 border-t border-b border-r items-center"}
           id="workspaces-menu"
           phx_update="ignore"
           data-dropdown="workspaces-menu-content">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
          <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
        </svg>
      </div>
      <div class="hidden absolute bg-blue-600 flex flex-col
                  top-full right-0 min-w-max" id="workspaces-menu-content">
        <%= for w <- @workspaces do %>
          <.lnk label={tr(w.name, 32)}
                href={workspace_dashboard_path(Endpoint, :index, w.id)}
                style="sub-menu"
             />
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
