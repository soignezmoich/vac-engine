defmodule VacEngineWeb.FormatHelpers do
  def format_date(nil), do: "-"

  def format_date(date) do
    Timex.format!(date, "{relative}", :relative)
  end

  def format_bool(false), do: "no"
  def format_bool(true), do: "yes"

  def tr(str, length \\ 16)
  def tr(str, length) when byte_size(str) < length, do: str

  def tr(str, length) do
    String.slice(str, 0..(length - 1)) <> "…"
  end
end
