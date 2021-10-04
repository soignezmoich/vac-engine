defmodule VacEngine.Blueprints.ExpressionType do
  use Ecto.Type

  alias VacEngine.Processor.Expression

  def type, do: :map

  def cast(data) do
    Expression.new(data)
  end

  def load(expr) do
    Expression.deserialize(expr)
  end

  def load(_data), do: :error

  def dump(%Expression{} = expr) do
    {:ok, Expression.serialize(expr)}
  end

  def dump(_), do: :error

  def embed_as(_format), do: :dump
end
