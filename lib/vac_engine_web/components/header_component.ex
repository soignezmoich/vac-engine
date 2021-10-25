defmodule VacEngineWeb.HeaderComponent do
  use VacEngineWeb, :component
  alias VacEngineWeb.Endpoint
  import Routes

  def header(assigns) do
    ~H"""
    <header
      class="flex font-bold flex-shrink-0 flex-col bg-gray-200
             flex-grow-0 z-10 border-b border-black">

      <!-- MAIN MENU -->

      <nav class="flex bg-blue-700 text-white">
        <div class="flex-grow">
          <div class="w-1.5 h-10"/>
          <div class="w-1.5 h-5"/>
        </div>

         <!-- Admin tab -->

        <%= if can?(@role, :manage, :users) do %>
          <.lnk label="Admin"
                href={user_path(Endpoint, :index)}
                style="main-menu"
                sel={at(@location, :admin)} />

          <div class="w-3"/>
        <% end %>


        <!-- Workspace tab + selector -->

        <%= if can?(@role, :access, :workspaces) do %>
          <%= if @workspace do %>
            <.lnk label="Workspace"
                  href={workspace_dashboard_path(Endpoint, :index, @workspace.id)}
                  subtitle={@workspace.name}
                  style="main-menu"
                  sel={at(@location, :workspace)} />
          <% else %>
            <.lnk label="Workspace"
                  href={nav_path(Endpoint, :index)}
                  style="main-menu"
                  sel={at(@location, :workspace)} />
          <% end %>

          <%= if (
            @workspaces
            && Enum.count(@workspaces) > 1
          ) do %>
            <.workspaces_menu workspace={@workspace}
                              workspaces={@workspaces}
                              sel={at(@location, :workspace)} />
          <% end %>

          <div class="w-3"/>
        <% end %>

        <!-- Editor tab -->

        <%= if can?(@role, :access, :editor) do %>
          <%= if @blueprint do %>
            <.lnk label="Editor"
                  href={workspace_blueprint_path(Endpoint, :index, @workspace.id)}
                  subtitle={@blueprint.name}
                  style="main-menu"
                  sel={at(@location, :blueprint)} />
          <% else %>
            <%= if @workspace do %>
              <.lnk label="Editor"
                    href={workspace_blueprint_path(Endpoint, :pick, @workspace.id)}
                    style="main-menu"
                    sel={at(@location, :blueprint)} />
            <% else %>
              <.disabled_lnk label="Editor"
                    subtitle={"pick workspace first"}
                    style="main-menu" />
            <% end %>
          <% end %>
        <% end %>

        <div class="w-20"/>

        <!-- login/logout button -->

        <%= if @role do %>
          <.lnk label="Logout ->"
                href={logout_path(Endpoint, :logout)} />
        <% else %>
          <.lnk label="-> Login"
                href={login_path(Endpoint, :form)} />
        <% end %>

        <div class="w-1.5"/>
      </nav>

      <!-- SUB MENU -->

      <nav class="xl:-mt-9 w-1/3">
        <div class="flex -mt-px">

        <div class="w-5"/>

        <!-- Admin sub menu -->

        <%= if at(@location, :admin) do %>
          <div>
            <.lnk label="Users"
                  href={user_path(Endpoint, :index)}
                  style="sub-menu"
                  sel={at(@location, :admin, :user)} />
          </div>
          <div>
            <.lnk label="API Keys"
                  href={api_key_path(Endpoint, :index)}
                  style="sub-menu"
                  sel={at(@location, :admin, :api_key)} />
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
          <div>
            <.lnk label="Portals"
                  href={workspace_portal_path(Endpoint, :index, @workspace.id)}
                  style="sub-menu"
                  sel={at(@location, :workspace, :pub)} />
          </div>
        <% end %>

        <%= if at(@location, :workspace, :nav) do %>
          <div class="flex-grow">
            <.lnk label="Available workspaces"
                  href={nav_path(Endpoint, :index)}
                  style="sub-menu"
                  sel={true} />
          </div>
        <% end %>

        <!-- Blueprint sub menu -->
        <%= if at(@location, :blueprint) do %>
          <%= if !at(@location,:blueprint, :pick) && !is_nil(@blueprint) do %>
            <div>
              <.lnk label="Summary"
                    href={workspace_blueprint_path(Endpoint, :summary, @workspace.id, @blueprint.id)}
                    style="sub-menu"
                    sel={at(@location, :blueprint, :summary)} />
            </div>
            <div>
              <.lnk label="Variables"
                    href={workspace_blueprint_path(Endpoint, :variables, @workspace.id, @blueprint.id)}
                    style="sub-menu"
                    sel={at(@location, :blueprint, :variables)} />
            </div>
            <div>
              <.lnk label="Deductions"
                    href={workspace_blueprint_path(Endpoint, :deductions, @workspace.id, @blueprint.id)}
                    style="sub-menu"
                    sel={at(@location, :blueprint, :deductions)} />
            </div>
            <div>
              <.lnk label="Import"
                href={workspace_blueprint_path(Endpoint, :import, @workspace.id, @blueprint.id)}
                style="sub-menu"
                sel={at(@location, :blueprint, :import)} />
            </div>
          <% else %>
            <div>
              <.lnk label="Available blueprints"
                    href={workspace_blueprint_path(Endpoint, :pick, @workspace.id)}
                    style="sub-menu"
                    sel={true} />
            </div>
          <% end %>
        <% end %>
        </div>
      </nav>
    </header>
    """
  end

  defp lnk(assigns) do
    assigns =
      assigns
      |> Map.get(:sel)
      |> case do
        nil -> assign(assigns, sel: false)
        _ -> assigns
      end

    assigns =
      assigns
      |> case do
        %{style: "main-menu", sel: sel} ->
          sel_style =
            if sel do
              "bg-white bg-opacity-20"
            else
              ""
            end

          assign(assigns,
            style_classes:
              "shadow-lg border text-white my-1.5 px-4 flex-grow hover:bg-white hover:bg-opacity-30 #{sel_style}",
            padding: "px-8"
          )

        %{style: "sub-menu", sel: sel} ->
          sel_style =
            if sel do
              "-mb-1 pb-px bg-cream-50"
            else
              "bg-gray-300"
            end

          assign(assigns,
            style_classes:
              "flex-grow text-black border-t border-l border-r border-black mt-2 mx-1 #{sel_style}",
            padding: "px-4 pt-1"
          )

        %{style: "menu-option", sel: sel} ->
          sel_style =
            if sel do
              "bg-white bg-opacity-20"
            else
              "bg-opacity-50"
            end

          assign(assigns,
            style_classes:
              "flex-grow bg-blue-800 border-black m-1 hover:bg-white hover:bg-opacity-30 #{sel_style}",
            padding: "px-4 py-1"
          )

        %{} ->
          assign(assigns, style_classes: "italic", padding: "px-4", style: nil)
      end

    assigns =
      assigns
      |> Map.get(:subtitle)
      |> case do
        nil -> assign(assigns, subtitle: nil)
        _ -> assigns
      end

    ~H"""
    <div class="flex flex-shrink-0">
      <%= live_redirect to: @href,
          class: "#{@sel} #{@style_classes}" do %>

        <div class="flex items-center h-full hover:drop-shadow hover:filter">
          <div>
            <div class={"#{@padding} text-center"}>
              <%= @label %>
            </div>
            <%= if @subtitle do %>
              <div class="text-xs italic font-light text-center max-w-2xs truncate">
                <%= @subtitle %>
              </div>
            <% end %>
          </div>
          <%= if @style == "main-menu" do %>
            <div>
              <div class="h-6"/>
              <div class="h-6"/>
            </div>
          <% end %>
        </div>

      <% end %>
    </div>
    """
  end

  defp disabled_lnk(assigns) do
    assigns =
      assigns
      |> Map.get(:style)
      |> case do
        "main-menu" ->
          assign(assigns,
            style_classes:
              "border border-grey-400 my-1.5 px-4 flex-grow opacity-50"
          )

        "sub-menu" ->
          assign(assigns, style_classes: "flex-grow")

        _ ->
          assign(assigns, style_classes: "")
      end

    assigns =
      assigns
      |> Map.get(:subtitle)
      |> case do
        nil -> assign(assigns, subtitle: nil)
        _ -> assigns
      end

    ~H"""
    <div class="flex flex-shrink-0">
      <div class={"#{@style_classes}"}>
        <div class="flex items-center h-full text-white">
          <div>
            <div class="px-8 text-center">
              <%= @label %>
            </div>
            <%= if @subtitle do %>
              <div class="text-sm font-light text-center">
                <%= @subtitle %>
              </div>
            <% end %>
          </div>
          <%= if @style == "main-menu" do %>
            <div>
              <div class="h-6"/>
              <div class="h-6"/>
            </div>
          <% end %>
        </div>
      </div>
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
        true -> assign(assigns, sel: "bg-white bg-opacity-20")
        _ -> assign(assigns, sel: "")
      end

    # <%= tr(@workspace.name, 32) %>

    ~H"""
    <div class="relative flex">
      <div class={"flex cursor-default
                  hover:bg-white hover:bg-opacity-30 #{@sel} my-1.5 border-t border-b border-r items-center"}
           id="workspaces-menu"
           phx-update="ignore"
           data-dropdown="workspaces-menu-content">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
          <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
        </svg>
      </div>
      <div class="hidden absolute bg-blue-700 flex flex-col
                  top-full right-0 min-w-max" id="workspaces-menu-content">
        <%= for w <- @workspaces do %>
          <.lnk label={tr(w.name, 32)}
                href={workspace_dashboard_path(Endpoint, :index, w.id)}
                style="menu-option"
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
