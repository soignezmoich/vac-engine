defmodule VacEngineWeb.HeaderComponent do
  use VacEngineWeb, :component

  import Routes
  import VacEngineWeb.IconComponent
  import VacEngineWeb.VersionHelpers

  alias VacEngine.Account
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
        <.blueprints_element
          role={@role}
          workspace={@workspace}
          blueprint={@blueprint}
          selected={at(@location, :blueprint)} />
        <.portals_element
          role={@role}
          workspace={@workspace}
          selected={at(@location, :portal)} />
        <div class="flex whitespace-nowrap pl-2 font-bold items-center text-xl text-white italic truncate">
          <.title {assigns} /> <%= inspect(@location)%>
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

  defp title(%{blueprint: nil} = assigns) do
    ~H""
  end

  defp title(%{blueprint: _blueprint} = assigns) do
    ~H"""
      &gt; Blueprint #<%= @blueprint.id%>: <%= @blueprint.name %>
    """
  end

  defp title(assigns) do
    ~H"""
      "default title"
    """
  end

  defp blueprints_element(%{role: nil} = assigns) do
    ~H""
  end

  defp blueprints_element(%{workspace: nil} = assigns) do
    ~H""
  end

  defp blueprints_element(%{role: _role} = assigns) do
    ~H"""
    <%= live_patch "Blueprints",
    to: Routes.workspace_blueprint_path(Endpoint, :index, @workspace.id),
    class: "flex
    my-1 mx-1 px-6 py-2
    items-center
    border rounded
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
    ~H"""
    <%= live_patch "Portals",
    to: Routes.workspace_portal_path(Endpoint, :index, @workspace),
    class: "flex
    m-1 px-4 py-2
    items-center
    border rounded
    shadow-md
    text-gray-50 bg-blue-800 hover:bg-blue-700 border-blue-500
    font-bold" %>
    """
  end

  defp account_element(%{role: nil} = assigns) do
    ~H"""
    <div class={
          "px-2 font-bold text-gray-50 font-lg italic flex
           items-stretch border border-blue-500"}>
      <%= live_patch "Login", to: login_path(Endpoint, :form), class: "items-center flex" %>
    </div>
    """
  end

  defp account_element(%{role: _role} = assigns) do
    ~H"""
    <div class="font-normal flex w-12 h-12 shadow-md item-center justify-center
      text-sm mx-1 my-1 px-2 pt-1 text-gray-50 rounded-full
      cursor-pointer bg-blue-800 hover:bg-blue-700 border border-blue-500 pt-0.5">
      <.icon name="hero/user" width="2rem" />
    </div>
    """
  end


  defp sub_element(assigns) do
    bg_color = if assigns.s do
      "bg-white"
    else
      "bg-cream-100 hover:bg-cream-50"
    end

    assigns = assign(assigns, bg_color: bg_color)

    ~H"""
    <%= live_patch @l,
    to: @a,
    class: "flex items-center
    m-1 px-4
    border rounded-sm
    shadow
    hover:shadow-md
    text-gray-900 #{@bg_color} border-cream-300
    " %>
    """
  end

  defp sub_elements(%{role: nil}) do
    []
  end

  defp sub_elements(%{
         location: [:blueprint, loc | loc2],
         workspace: w,
         blueprint: b
       })
       when not is_nil(w) and not is_nil(b) do

    [
      %{
        l: "Blueprint",
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
      # %{
      #   l: "Import",
      #   a: workspace_blueprint_path(Endpoint, :import, w.id, b.id),
      #   s: loc == :import,
      #   i: "hero/sort-ascending"
      # },
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
      # %{
      #   l: "Dashboard",
      #   a: workspace_dashboard_path(Endpoint, :index, w.id),
      #   s: loc == :dashboard
      # },
      # %{
      #   l: "Blueprints",
      #   a: workspace_blueprint_path(Endpoint, :index, w.id),
      #   s: loc == :blueprint
      # },
      # %{
      #   l: "Portals",
      #   a: workspace_portal_path(Endpoint, :index, w.id),
      #   s: loc == :portal
      # }
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
