defmodule VacEngineWeb.Api.PubView do
  use VacEngineWeb, :view

  def render("result.json", %{result: result}) do
    %{input: result.input, output: result.output}
  end
end
