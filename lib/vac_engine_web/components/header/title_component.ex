defmodule VacEngineWeb.Header.TitleComponent do
  @moduledoc """
  The title in the middle of the header. It depends on the current context.
  """

  use VacEngineWeb, :component

  def title(%{portal: portal} = assigns) when not is_nil(portal) do
    ~H"""
      #<%= @portal.id%> - <%= tr @portal.name, 24 %>
    """
  end

  def title(%{blueprint: blueprint} = assigns) when not is_nil(blueprint) do
    ~H"""
      #<%= @blueprint.id%> - <%= tr @blueprint.name, 24 %>
    """
  end

  def title(assigns) do
    ~H""
  end
end
