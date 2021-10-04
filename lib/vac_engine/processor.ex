defmodule VacEngine.Processor do
  alias VacEngine.Processor.Compiler
  alias VacEngine.Blueprints.Blueprint
  alias VacEngine.Processor.State
  alias VacEngine.Processor

  defstruct blueprint: nil, compiled_ast: nil, state: nil

  def compile_blueprint(%Blueprint{} = blueprint) do
    Compiler.compile_blueprint(blueprint)
    |> case do
      {:ok, compiled_ast} ->
        state = State.new(blueprint.variables)
        {:ok, %Processor{compiled_ast: compiled_ast, state: state}}

      e ->
        e
    end
  end

  def run(%Processor{} = processor, input) do
    state = State.map_input(processor.state, input)

    Compiler.eval_ast(processor.compiled_ast, state)
    |> case do
      {:ok, state} ->
        state = State.finalize_output(state)
        {:ok, state.output}

      err ->
        err
    end
  end
end
