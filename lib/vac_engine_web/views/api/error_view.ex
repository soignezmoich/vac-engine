defmodule VacEngineWeb.Api.ErrorView do
  use VacEngineWeb, :view

  def render("error.json", %{error: msg}) do
    %{error: msg}
  end
end
