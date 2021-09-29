defmodule VacEngine.Processor do
  alias VacEngine.Processor.Compiler
  alias VacEngine.Blueprints.Blueprint
  alias VacEngine.Processor

  defstruct blueprint: nil, compiled_ast: nil

  def compile_blueprint(%Blueprint{} = blueprint) do
    Compiler.compile_blueprint(blueprint)
    |> case do
      {:ok, compiled_ast} ->
        {:ok, %Processor{blueprint: blueprint, compiled_ast: compiled_ast}}

      e ->
        e
    end
  end

  def run(%Processor{} = processor, input_binding) do
    Compiler.eval_ast(processor.compiled_ast, input_binding)
  end
end
