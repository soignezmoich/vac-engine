defmodule VacEngine.Processor.Blueprint.ExpressionType do
  use Ecto.Type

  alias VacEngine.Processor.Compiler.Expression

  def type, do: :map

  def cast(data) do
    Expression.new(data)
  end

  def load(%Expression{} = expr) do
    {:ok, expr}
  end

  def load(_data), do: :error

  def dump(%Expression{} = expr) do
    {:ok, expr}
  end

  def dump(_), do: :error
end
