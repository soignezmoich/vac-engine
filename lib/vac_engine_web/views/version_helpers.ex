defmodule VacEngineWeb.VersionHelpers do
  @build_date Timex.format!(Timex.now(), "%d.%m.%Y", :strftime)
  @version System.cmd("git", ["describe", "--always"]) |> elem(0)

  def build_date do
    @build_date
  end

  def version do
    @version
  end
end
