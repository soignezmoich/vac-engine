defmodule VacEngine.Processor.Blueprint.NameType do
  use Ecto.Type


  def type, do: :string

  def cast(data) when is_atom(data) do
    data
    |> to_string
    |> cast
  end

  def cast(data) when is_binary(data) do
    if String.match?(data, ~r/^[a-z_][a-z0-9_]*$/) do
      {:ok, data}
    else
      {:error, [message: "invalid format"]}
    end
  end

  def cast(_), do: :error

  def load(str) when is_binary(str) do
    {:ok, str}
  end

  def load(_data), do: :error

  def dump(str) when is_binary(str) do
    {:ok, str}
  end

  def dump(_), do: :error

end
