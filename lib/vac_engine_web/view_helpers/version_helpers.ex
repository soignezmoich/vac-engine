defmodule VacEngineWeb.VersionHelpers do
  @moduledoc false

  def build_date do
    VacEngine.build_date()
  end

  def version do
    VacEngine.version()
  end
end
