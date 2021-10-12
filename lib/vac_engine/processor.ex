defmodule VacEngine.Processor do
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Blueprints
  alias VacEngine.Processor.Compiler
  alias VacEngine.Processor.State
  alias VacEngine.Processor

  defdelegate create_blueprint(workspace, attrs), to: Blueprints
  defdelegate fetch_blueprint(workspace, bid), to: Blueprints
  defdelegate list_blueprints(workspace), to: Blueprints
  defdelegate get_blueprint!(blueprint_id), to: Blueprints

  defstruct blueprint: nil, compiled_ast: nil, state: nil

  def compile_blueprint(%Blueprint{} = blueprint) do
    with {:ok, compiled_ast} <- Compiler.compile_blueprint(blueprint),
         {:ok, state} <- State.new(blueprint.variables) do
      {:ok, %Processor{compiled_ast: compiled_ast, state: state}}
    else
      {:error, err} ->
        {:error, "cannot compile blueprint: #{err}"}
    end
  end

  def run(%Processor{} = processor, input) do
    with {:ok, state} <- State.map_input(processor.state, input),
         {:ok, state} <- Compiler.eval_ast(processor.compiled_ast, state),
         {:ok, state} <- State.finalize_output(state) do
      {:ok, state}
    else
      {:error, msg} ->
        {:error, msg}
    end
  end
end
