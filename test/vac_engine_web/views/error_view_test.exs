defmodule VacEngineWeb.ErrorViewTest do
  use VacEngineWeb.ConnCase, async: true

  import Phoenix.View

  # check that error pages are static html files
  test "renders XXX.html" do
    for err <- [401, 403, 404, 500] do
      assert render_to_string(VacEngineWeb.ErrorView, "#{err}.html", []) ==
               File.read!("lib/vac_engine_web/templates/error/#{err}.html.eex")
    end
  end
end
