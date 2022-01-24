defmodule VacEngine.Convert do

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
