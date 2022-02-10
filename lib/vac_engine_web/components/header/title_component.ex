defmodule VacEngineWeb.Header.TitleComponent do
  use VacEngineWeb, :component



  def title(%{blueprint: nil} = assigns) do
    ~H""
  end

  def title(%{blueprint: _blueprint} = assigns) do
    ~H"""
      #<%= @blueprint.id%> - <%= @blueprint.name %>
    """
  end

  def title(assigns) do
    ~H"""
      "default title"
    """
  end
end
