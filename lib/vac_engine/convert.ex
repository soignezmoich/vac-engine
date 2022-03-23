defmodule VacEngine.Convert do
  @moduledoc """
  Utility to parse a string to a given type, returning meaningful errors
  if parsing is impossible.

  The parsing itself is done by the VacEngine.Processor.Convert module.
  """

  import VacEngine.PipeHelpers

  def parse_string(str, type) do
    try do
      VacEngine.Processor.Convert.parse_string(str, type)
      |> ok()
    catch
      _ -> {:error, format_error(str, type)}
    end
  end

  defp format_error(_value, :date) do
    "format is YYYY-MM-DD"
  end

  defp format_error(_value, :datetime) do
    "format is YYYY-MM-DD hh:mm:ss"
  end

  defp format_error(_value, :boolean) do
    "format is true or false"
  end

  defp format_error(value, :integer) do
    "invalid integer #{value}"
  end

  defp format_error(value, :number) do
    "invalid number #{value}"
  end

  defp format_error(value, _) do
    "invalid value #{value}"
  end
end
