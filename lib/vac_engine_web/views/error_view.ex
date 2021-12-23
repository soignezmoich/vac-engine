defmodule VacEngineWeb.ErrorView do
  use VacEngineWeb, :view

  def template_not_found(_template, assigns) do
    render("500.html", assigns)
  end

  def render("400.json", _assigns) do
    %{error: "Bad request"}
  end

  def render("401.json", _assigns) do
    %{error: "Unauthorized"}
  end

  def render("403.json", _assigns) do
    %{error: "Access denied"}
  end

  def render("404.json", _assigns) do
    %{error: "Not found"}
  end

  def render("500.json", _assigns) do
    %{error: "Server error"}
  end
end
