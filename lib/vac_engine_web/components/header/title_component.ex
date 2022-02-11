defmodule VacEngineWeb.Header.TitleComponent do
  use VacEngineWeb, :component

  def title(%{portal: portal} = assigns) when not is_nil(portal) do
    ~H"""
      #<%= @portal.id%> - <%= @portal.name %>
    """
  end

  def title(%{blueprint: blueprint} = assigns) when not is_nil(blueprint) do
    ~H"""
      #<%= @blueprint.id%> - <%= @blueprint.name %>
    """
  end

  def title(assigns) do
    ~H""
  end
end
