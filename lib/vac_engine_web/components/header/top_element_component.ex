defmodule VacEngineWeb.Header.TopElementComponent do
  use VacEngineWeb, :component

  import VacEngineWeb.IconComponent

  # No workspace selected

  def top_elements(%{
        location: [:workspace, :nav]
      }) do
    []
  end

  def top_elements(%{
        workspace: nil,
        workspaces: [_ | _]
      }) do
    [
      %{
        l: "Back to workspace",
        a: Routes.welcome_url(Endpoint, :index),
        s: false,
        i: "hero/arrow-sm-left"
      }
    ]
  end

  def top_elements(%{location: loc, workspace: nil}) when is_list(loc) do
    []
  end

  def top_elements(%{location: loc, workspace: w}) when is_list(loc) do
    [
      %{
        l: "Blueprints",
        a: Routes.workspace_blueprint_path(Endpoint, :index, w.id),
        s: :blueprint in loc,
        i: "hero/menu-alt-1"
      },
      %{
        l: "Portals",
        a: Routes.workspace_portal_path(Endpoint, :index, w.id),
        s: :portal in loc,
        i: "hero/switch-vertical"
      }
    ]
  end

  def top_elements(_) do
    []
  end

  def top_element(assigns) do
    bg_color =
      if assigns.s do
        "bg-blue-800 border-blue-600"
      else
        "bg-blue-600 hover:bg-blue-700 border-blue-500"
      end

    l =
      if assigns.i do
        ~H"""
        <.icon name={assigns.i} width="1.5rem" class="inline" />
        <div class="pl-1"><%= @l %></div>
        """
      else
        assigns.l
      end

    assigns =
      assign(assigns,
        l: l,
        bg_color: bg_color
      )

    ~H"""
    <%= live_patch @l,
    to: @a,
    class: "flex
    m-1 px-4 py-2
    items-center
    border rounded-sm
    shadow-md
    text-gray-50 #{@bg_color}
    font-bold" %>
    """
  end
end
