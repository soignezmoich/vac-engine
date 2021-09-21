defmodule VacEngineWeb.FormatHelpers do

  def format_date(nil), do: "-"
  def format_date(date) do
    Timex.format!(date, "{relative}", :relative)
  end

  def format_bool(false), do: "no"
  def format_bool(true), do: "yes"

end
