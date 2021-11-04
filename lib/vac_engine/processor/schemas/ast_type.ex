defmodule VacEngine.Processor.AstType do
  @moduledoc """
  Ecto type for AST serialization to the database.

  Allow to store tuples as JSON
  """
  use Ecto.Type

  alias VacEngine.Processor.Ast

  def type, do: :map

  def cast(data) do
    Ast.sanitize(data)
  end

  def load(ast) do
    Ast.deserialize(ast)
  end

  def dump(ast) do
    Ast.serialize(ast)
  end

  def embed_as(_format), do: :dump
end
