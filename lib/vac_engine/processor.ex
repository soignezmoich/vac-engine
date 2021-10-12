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
    Compiler.compile_blueprint(blueprint)
    |> case do
      {:ok, compiled_ast} ->
        state = State.new(blueprint.variables)
        {:ok, %Processor{compiled_ast: compiled_ast, state: state}}

      e ->
        e
    end
  catch
    {_code, msg} ->
      {:error, msg}
  end

  def run(%Processor{} = processor, input) do
    state = State.map_input(processor.state, input)

    Compiler.eval_ast(processor.compiled_ast, state)
    |> case do
      {:ok, state} ->
        state = State.finalize_output(state)
        {:ok, state}

      {:error, msg} ->
        {:error, msg}

      err ->
        {:error, err}
    end
  catch
    {_code, msg} ->
      {:error, msg}
  end
end
