defmodule VacEngine.Processor do
  alias VacEngine.Processor
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Blueprints
  alias VacEngine.Processor.Compiler
  alias VacEngine.Processor.State
  alias VacEngine.Processor.Variables
  alias VacEngine.Processor.Info

  defdelegate create_blueprint(workspace, attrs), to: Blueprints
  defdelegate update_blueprint(blueprint, attrs), to: Blueprints
  defdelegate fetch_blueprint(workspace, bid), to: Blueprints
  defdelegate list_blueprints(workspace), to: Blueprints
  defdelegate get_blueprint!(blueprint_id), to: Blueprints
  defdelegate serialize_blueprint(blueprint), to: Blueprints

  defdelegate create_variable(parent, attrs), to: Variables
  defdelegate update_variable(var, attrs), to: Variables
  defdelegate delete_variable(var), to: Variables
  defdelegate move_variable(var, new_parent), to: Variables

  defstruct blueprint: nil, compiled_ast: nil, state: nil, info: nil

  def compile_blueprint(%Blueprint{} = blueprint) do
    with {:ok, compiled_ast} <- Compiler.compile_blueprint(blueprint),
         {:ok, info} <- Info.describe(blueprint),
         {:ok, state} <- State.new(blueprint.variables) do
      {:ok,
       %Processor{
         compiled_ast: compiled_ast,
         state: state,
         blueprint: blueprint,
         info: info
       }}
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
