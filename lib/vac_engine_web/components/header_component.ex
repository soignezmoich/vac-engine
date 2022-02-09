defmodule VacEngineWeb.HeaderComponent do
  use VacEngineWeb, :component

  import Routes
  import VacEngineWeb.IconComponent

  alias VacEngineWeb.Endpoint
  import VacEngineWeb.VersionHelpers

  def header(assigns) do
    ~H"""
    <header class="flex flex-col xl:flex-row relative
                   bg-blue-700 border-b border-gray-900">
      <div class="absolute top-0 left-0 py-1 px-3 text-xs text-gray-200">
        Version: <%= version() %>.
        Build date: <%= build_date() %>.
      </div>
      <nav class="flex mx-2 order-2 xl:order-1">
        <%= for attrs <- sub_elements(assigns) do %>
          <.sub_element {attrs} />
        <% end %>
      </nav>
      <div class="xl:flex-grow xl:order-2"></div>
      <nav class="flex mx-2 order-1 xl:order-3 self-end xl:self-stretch
                  items-stretch h-16">
        <.admin_element role={@role} s={at(@location, :admin)} />
        <.workspace_element
          role={@role}
          workspace={@workspace}
          workspaces={@workspaces}
          s={at(@location, :workspace)} />
        <.blueprint_element
          role={@role}
          workspace={@workspace}
          blueprint={@blueprint}
          s={at(@location, :blueprint)} />
        <%= for attrs <- top_elements(assigns) do %>
          <.top_element {attrs} />
        <% end %>
      </nav>
    </header>
    """
  end

  defp blueprint_element(%{role: nil} = assigns) do
    ~H""
  end

  defp blueprint_element(%{workspace: nil} = assigns) do
    ~H"""
      <div class="border border-gray-400 my-1 ml-4 flex flex-col justify-center
                  items-center px-2 font-bold text-gray-300">
        Editor
        <div class="italic text-sm font-normal">
          Pick workspace first
        </div>
      </div>
    """
  end

  defp blueprint_element(%{role: _role} = assigns) do
    ~H"""
      <div class={klass("border border-gray-50 my-1 shadow-md flex
               text-gray-50 ml-4",
              {"bg-gray-100 bg-opacity-20", Map.get(assigns, :s)})}>
        <div class="flex flex-col items-center justify-center px-2">
          <%= cond do %>
          <% is_nil(@workspace) -> %>
            <div>Editor</div>
          <% not is_nil(@blueprint) -> %>
            <div class="font-bold px-6">Editor</div>
            <div class="text-sm italic"><%= @blueprint.name %></div>
          <% true -> %>
            <%= live_patch "Editor",
              to: workspace_blueprint_path(Endpoint, :pick, @workspace),
              class: "font-bold px-6" %>
          <% end %>
        </div>
      </div>
    """
  end

  defp workspace_element(%{role: nil} = assigns) do
    ~H""
  end

  defp workspace_element(%{role: _role} = assigns) do
    ~H"""
      <div class={klass("border border-gray-50 my-1 shadow-md flex
               text-gray-50",
              {"bg-gray-100 bg-opacity-20", Map.get(assigns, :s)})}>
        <div class="flex flex-col items-center justify-center px-2">
          <%= if @workspace do %>
            <%= live_patch "Workspace",
              to: workspace_dashboard_path(Endpoint, :index, @workspace),
              class: "font-bold px-6" %>
            <%= live_patch @workspace.name,
              to: workspace_dashboard_path(Endpoint, :index, @workspace),
              class: "text-sm italic" %>
          <% else %>
            <%= live_patch "Workspace",
              to: nav_path(Endpoint, :index),
              class: "font-bold px-6 flex-grow flex items-center" %>
          <% end %>
        </div>
        <%= case @workspaces do %>
        <% [_a, _b | _] -> %>
          <div class="border-l border-gray-50 flex justify-center items-center px-1 relative"
                id="workspace-dropdown-menu"
                data-dropdown="workspace-dropdown">
            <.icon name="hero/chevron-double-down" width="18px" />
            <div id="workspace-dropdown"
                 class="absolute top-full right-0 bg-blue-700 z-50 border
                 mt-px -mr-px m-w-0 min-w-min hidden
                 border-blue-800 py-2">
              <%= for w <- Enum.take(@workspaces, 10) do %>
                <%= live_redirect(tr(w.name, 32),
                  to: workspace_dashboard_path(Endpoint, :index, w),
                  class: "font-bold px-6 py-1 whitespace-nowrap flex-grow flex
                  items-center hover:bg-gray-50 hover:bg-opacity-30") %>
              <% end %>
              <%= if Enum.count(@workspaces) > 10 do %>
                <div class="px-6 text-sm py-4 italic w-64">
                You have access to more workspaces, the list has been truncated.
                </div>
                <%= live_patch "Full list",
                  to: nav_path(Endpoint, :index),
                  class: "font-bold px-6 py-1 whitespace-nowrap flex-grow flex
                  items-center hover:bg-gray-50 hover:bg-opacity-30" %>
              <% end %>
            </div>
          </div>
        <% _ -> %>
        <% end %>
      </div>
    """
  end

  defp admin_element(
         %{role: %{global_permission: %{super_admin: true}}} = assigns
       ) do
    ~H"""
      <div class={klass(
          "border border-gray-50 my-1 shadow-md mr-4 flex items-stretch",
          {"bg-gray-100 bg-opacity-20", Map.get(assigns, :s)}
        )}>
        <%= live_patch "Admin",
          to: user_path(Endpoint, :index),
          class: "block font-bold px-6 text-gray-50 flex items-center" %>
      </div>
    """
  end

  defp admin_element(%{role: _} = assigns) do
    ~H""
  end

  defp top_element(assigns) do
    ~H"""
    <div class={klass(
          "px-4 font-bold text-gray-50 font-lg italic flex
           items-stretch",
          {"bg-blue-600", Map.get(assigns, :s)})}>
      <%= live_patch @l, to: @a, class: "items-center flex" %>
    </div>
    """
  end

  defp sub_element(assigns) do
    ~H"""
      <div class={klass(
        "mx-1 font-bold border-t border-r border-l border-gray-900
         self-end relative flex items-center px-2 ",
        [
          {"bg-cream-50 mt-px", Map.get(assigns, :s)},
          {"bg-gray-200", !Map.get(assigns, :s)}
        ]
      )}>

      <%= if Map.get(assigns, :i) do %>
        <div class="mr-2"><.icon name={@i} width="24px" /></div>
      <% end %>
      <%= live_patch @l, to: @a, class: "py-0.5 block" %>
      <%= if Map.get(assigns, :s) do %>
        <div class="absolute left-0 right-0 -bottom-px h-px bg-cream-50">
        </div>
      <% end %>
    </div>
    """
  end

  defp top_elements(%{role: nil}) do
    [
      %{l: "→ Login", a: login_path(Endpoint, :form)}
    ]
  end

  defp top_elements(%{role: _role}) do
    [
      %{l: "Logout →", a: logout_path(Endpoint, :logout)}
    ]
  end

  defp top_elements(_) do
    []
  end

  defp sub_elements(%{role: nil}) do
    []
  end

  defp sub_elements(%{
         location: [:blueprint, loc | _],
         workspace: w,
         blueprint: b
       })
       when not is_nil(w) and not is_nil(b) do
    [
      %{
        l: "Summary",
        a: workspace_blueprint_path(Endpoint, :summary, w.id, b.id),
        s: loc == :summary,
        i: "hero/clipboard-list"
      },
      %{
        l: "Variables",
        a: workspace_blueprint_path(Endpoint, :variables, w.id, b.id),
        s: loc == :variables,
        i: "hero/variable"
      },
      %{
        l: "Deductions",
        a: workspace_blueprint_path(Endpoint, :deductions, w.id, b.id),
        s: loc == :deductions,
        i: "hero/chevron-double-right"
      },
      %{
        l: "Import",
        a: workspace_blueprint_path(Endpoint, :import, w.id, b.id),
        s: loc == :import,
        i: "hero/sort-ascending"
      },
      %{
        l: "Simulations",
        a: workspace_blueprint_path(Endpoint, :simulations, w.id, b.id),
        s: loc == :simulations,
        i: "hero/fast-forward"
      }
      # %{
      #   l: "Simulations test",
      #   a: workspace_blueprint_path(Endpoint, :simulations_test, w.id, b.id),
      #   s: loc == :simulations_test,
      #   i: "hero/fast-forward"
      # }
    ]
  end

  defp sub_elements(%{
         location: [:workspace, :nav | _]
       }) do
    [
      %{l: "Select workspace", a: nav_path(Endpoint, :index), s: true}
    ]
  end

  defp sub_elements(%{
         location: [:workspace, loc | _],
         workspace: w
       })
       when not is_nil(w) do
    [
      %{
        l: "Dashboard",
        a: workspace_dashboard_path(Endpoint, :index, w.id),
        s: loc == :dashboard
      },
      %{
        l: "Blueprints",
        a: workspace_blueprint_path(Endpoint, :index, w.id),
        s: loc == :blueprint
      },
      %{
        l: "Portals",
        a: workspace_portal_path(Endpoint, :index, w.id),
        s: loc == :portal
      }
    ]
  end

  defp sub_elements(%{
         location: [:admin, loc | _]
       }) do
    [
      %{l: "Users", a: user_path(Endpoint, :index), s: loc == :user},
      %{
        l: "Workspaces",
        a: workspace_path(Endpoint, :index),
        s: loc == :workspace
      },
      %{l: "API Keys", a: api_key_path(Endpoint, :index), s: loc == :api_key},
      %{
        l: "Maintenance",
        a: maintenance_path(Endpoint, :index),
        s:
          loc ==
            :maintenance
      }
    ]
  end

  defp sub_elements(_), do: []

  defp at([a | _], a), do: true
  defp at(_, _), do: false
  # defp at([a, b | _], a, b), do: true
  # defp at(_, _, _), do: false
end
