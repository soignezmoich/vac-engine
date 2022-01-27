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

  def parse_bool(b) do
    throw({:invalid_bool, "invalid bool #{b}"})
  end

  @date_formats ~w({YYYY}-{0M}-{0D} {YYYY})

  def parse_date(str) do
    parse_datetime(str, @date_formats)
    |> Timex.to_date()
    |> case do
      {:error, err} -> throw({:invalid_date, to_string(err)})
      res -> res
    end
  end

  @datetime_formats ~w({ISO:Extended} {YYYY}-{0M}-{0D} {YYYY})

  def parse_datetime(str) do
    parse_datetime(str, @datetime_formats)
  end

  def parse_datetime(str, fmts) do
    fmts
    |> Enum.find_value(fn fmt ->
      Timex.parse(str, fmt)
      |> case do
        {:ok, result} -> result |> Timex.to_naive_datetime()
        _ -> nil
      end
    end)
    |> case do
      nil -> throw({:invalid_input, "invalid string for date #{str}"})
      date -> date
    end
  end

  def parse_number(str) do
    Float.parse(str)
    |> case do
      {f, _} -> f
      _ -> throw({:invalid_number, "invalid number #{str}"})
    end
  end

  def parse_integer(str) do
    Integer.parse(str)
    |> case do
      {f, _} -> f
      _ -> throw({:invalid_number, "invalid integer #{str}"})
    end
  end

  def parse_string(str, _t) when not is_binary(str) do
    throw({:invalid_type, "#{str} cannot be parsed"})
  end

  def parse_string(str, :string), do: str
  def parse_string(str, :date), do: parse_date(str)
  def parse_string(str, :datetime), do: parse_datetime(str)
  def parse_string(str, :boolean), do: parse_bool(str)
  def parse_string(str, :number), do: parse_number(str)
  def parse_string(str, :integer), do: parse_integer(str)

  def parse_string(_str, t) do
    throw({:invalid_type, "type #{t} cannot be parsed"})
  end
end
