defmodule VacEngine.Processor.ListType do
  @moduledoc """
  Ecto type to allow storing a list in a jsonb field
  """
  use Ecto.Type

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
