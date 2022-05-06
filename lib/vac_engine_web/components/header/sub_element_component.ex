defmodule VacEngineWeb.Header.SubElementComponent do
  @moduledoc """
  The container for the sub-level section buttons.
  """

  use VacEngineWeb, :component

  import VacEngineWeb.IconComponent

  def sub_elements(%{role: nil}) do
    []
  end

  def sub_elements(%{
        location: [:blueprint, loc | _loc_tail],
        workspace: w,
        blueprint: b
      })
      when not is_nil(w) and not is_nil(b) do
    [
      %{
        l: "Overview",
        a: Routes.workspace_blueprint_path(Endpoint, :summary, w.id, b.id),
        s: loc == :summary,
        i: "hero/clipboard-list"
      },
      %{
        l: "Variables",
        a: Routes.workspace_blueprint_path(Endpoint, :variables, w.id, b.id),
        s: loc == :variables,
        i: "hero/variable"
      },
      %{
        l: "Deductions",
        a: Routes.workspace_blueprint_path(Endpoint, :deductions, w.id, b.id),
        s: loc == :deductions,
        i: "hero/chevron-double-right"
      },
      %{
        l: "Simulations",
        a: Routes.workspace_blueprint_path(Endpoint, :simulations, w.id, b.id),
        s: loc == :simulations,
        i: "hero/fast-forward"
      }
    ]
  end

  def sub_elements(%{
        location: [:workspace, :nav | _]
      }) do
    []
  end

  def sub_elements(%{
        location: [:workspace, _loc | _],
        workspace: w
      })
      when not is_nil(w) do
    []
  end

  def sub_elements(%{
        location: [:admin, loc | _]
      }) do
    [
      %{
        l: "Users",
        a: Routes.user_path(Endpoint, :index),
        i: "hero/users",
        s: loc == :user
      },
      %{
        l: "Workspaces",
        a: Routes.workspace_path(Endpoint, :index),
        i: "hero/view-grid",
        s: loc == :workspace
      },
      %{
        l: "API Keys",
        a: Routes.api_key_path(Endpoint, :index),
        i: "hero/key",
        s: loc == :api_key
      },
      %{
        l: "Maintenance",
        a: Routes.maintenance_path(Endpoint, :index),
        i: "hero/cog",
        s: loc == :maintenance
      }
    ]
  end

  def sub_elements(_), do: []

  def sub_element(assigns) do
    bg_color =
      if assigns.s do
        "bg-cream-600 text-cream-50 border-cream-800"
      else
        "bg-cream-100 hover:bg-cream-50 border-cream-300"
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
    class: "flex items-center
    m-1 2xl:px-4 px-2
    border rounded-sm
    shadow
    hover:shadow-md
    text-gray-900 #{@bg_color}
    " %>
    """
  end
end
