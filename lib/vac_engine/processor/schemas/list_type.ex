defmodule VacEngine.Processor.ListType do
  use Ecto.Type

  alias VacEngine.Processor.Ast

  def type, do: :map

  def cast(data) when is_list(data) do
    {:ok, data}
  end

  def cast(_), do: :error

  def load(data) when is_list(data) do
    {:ok, data}
  end

  def dump(data) when is_list(data) do
    {:ok, data}
  end

  def dump(_), do: :error

  def embed_as(_format), do: :dump
end
