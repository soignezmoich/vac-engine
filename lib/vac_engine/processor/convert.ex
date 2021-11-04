defmodule VacEngine.Processor.Convert do
  @moduledoc """
  Convert utilities
  """

  def parse_bool(true), do: true
  def parse_bool(false), do: false
  def parse_bool("1"), do: true
  def parse_bool("0"), do: false
  def parse_bool("true"), do: true
  def parse_bool("false"), do: false
  def parse_bool("yes"), do: true
  def parse_bool("no"), do: false
  def parse_bool("TRUE"), do: true
  def parse_bool("FALSE"), do: false
  def parse_bool("YES"), do: true
  def parse_bool("NO"), do: false

  @date_formats ~w({YYYY}-{0M}-{D} {YYYY})

  def parse_date(str) do
    parse_datetime(str, @date_formats)
    |> Timex.to_date()
    |> case do
      {:error, err} -> throw({:invalid_date, to_string(err)})
      res -> res
    end
  end

  @datetime_formats ~w({ISO:Extended} {YYYY}-{0M}-{D} {YYYY})

  def parse_datetime(str) do
    parse_datetime(str, @datetime_formats)
  end

  def parse_datetime(str, fmts) do
    fmts
    |> Enum.find_value(fn fmt ->
      Timex.parse(str, fmt)
      |> case do
        {:ok, result} -> result
        _ -> nil
      end
    end)
    |> case do
      nil -> throw({:invalid_input, "invalid string for date #{str}"})
      date -> date
    end
  end
end
