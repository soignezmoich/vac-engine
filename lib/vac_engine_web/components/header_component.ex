defmodule VacEngineWeb.HeaderComponent do
  use VacEngineWeb, :component
  alias VacEngineWeb.Endpoint
  import Routes
  import VacEngineWeb.IconComponent

  def header(assigns) do
    ~H"""
    <header class="flex flex-col lg:flex-row bg-blue-700 border-b border-gray-900">
      <nav class="flex mx-2 order-2 lg:order-1">
        <%= for attrs <- sub_elements(assigns) do %>
          <.sub_element {attrs} />
        <% end %>
      </nav>
      <div class="lg:flex-grow lg:order-2"></div>
      <nav class="flex mx-2 order-1 lg:order-3 self-end lg:self-stretch
                  items-stretch h-16">
        <.admin_element role={@role} s={at(@location, :admin)} />
        <.workspace_element
          role={@role}
          workspace={@workspace}
          workspaces={@workspaces}
          s={at(@location, :workspace)} />
        <%= for attrs <- top_elements(assigns) do %>
          <.top_element {attrs} />
        <% end %>
      </nav>
    </header>
    """
  end

  defp workspace_element(%{role: nil} = assigns) do
    ~H""
  end

  defp workspace_element(%{role: _role} = assigns) do
    ~H"""
      <div class={klass("border border-gray-50 my-1 shadow-md flex
               text-gray-50 px-2",
              {"bg-gray-100 bg-opacity-20", Map.get(assigns, :s)})}>
        <div class="flex flex-col items-center justify-center">
          <%= if @workspace do %>
            <%= live_patch "Workspace",
              to: workspace_dashboard_path(Endpoint, :index, @workspace),
              class: "font-bold px-6" %>
            <div class="text-sm italic"><%= @workspace.name %></div>
          <% else %>
            <%= live_patch "Workspace",
              to: nav_path(Endpoint, :index),
              class: "font-bold px-6 flex-grow flex items-center" %>
          <% end %>
        </div>
        <%= case @workspaces do %>
        <%= [_a, _b | _] -> %>
          <div class="border-l border-gray-50">
          </div>
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

  defp admin_element(%{role: nil} = assigns) do
    ~H""
  end

  defp klass(base, conditionals) when is_list(conditionals) do
    conditionals
    |> Enum.reduce([base], fn
      {n, true}, all -> [n | all]
      {_n, _}, all -> all
    end)
    |> Enum.join(" ")
  end

  defp klass(base, conditionals), do: klass(base, [conditionals])

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
        <div class="mr-2"><.icon name={@i} width="1.25rem" /></div>
      <% end %>
      <%= live_patch @l, to: @a, class: "py-0.5 block" %>
      <%= if Map.get(assigns, :s) do %>
        <div class="absolute bg-red-500 left-0 right-0 -bottom-px h-px
        bg-cream-50">
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
        i: "hero/home"
      },
      %{
        l: "Variables",
        a: workspace_blueprint_path(Endpoint, :variables, w.id, b.id),
        s: loc == :variables,
        i: "hero/puzzle"
      },
      %{
        l: "Deductions",
        a: workspace_blueprint_path(Endpoint, :deductions, w.id, b.id),
        s: loc == :deductions
      },
      %{
        l: "Import",
        a: workspace_blueprint_path(Endpoint, :import, w.id, b.id),
        s: loc == :import
      }
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
      %{l: "API Keys", a: api_key_path(Endpoint, :index), s: loc == :api_key}
    ]
  end

  defp sub_elements(_), do: []

  defp at([a | _], a), do: true
  defp at(_, _), do: false
  #defp at([a, b | _], a, b), do: true
  #defp at(_, _, _), do: false
end
