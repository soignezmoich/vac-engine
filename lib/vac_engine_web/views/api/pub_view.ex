defmodule VacEngineWeb.Api.PubView do
  use VacEngineWeb, :view

  def render("run.json", %{result: result}) do
    %{input: result.input, output: result.output}
  end

  def render("info.json", %{info: info}) do
    %{
      input: info.input,
      output: info.output,
      logic: info.logic
    }
  end
end
