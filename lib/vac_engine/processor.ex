defmodule VacEngine.Processor do
  alias VacEngine.Processor
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Blueprints
  alias VacEngine.Processor.Compiler
  alias VacEngine.Processor.State
  alias VacEngine.Processor.Variables
  alias VacEngine.Processor.Info

  @doc """
  Create a blueprint with attributes
  """
  defdelegate create_blueprint(workspace, attrs), to: Blueprints

  @doc """
  Cast attributes into a changeset

  Only root attributes are supported (no variables or deductions)
  """
  defdelegate change_blueprint(blueprint, attrs \\ %{}), to: Blueprints

  @doc """
  Update a blueprint with attributes
  """
  defdelegate update_blueprint(blueprint, attrs), to: Blueprints

  @doc """
  Get a blueprint with id, raise if not found.
  """
  defdelegate get_blueprint!(blueprint_id), to: Blueprints

  @doc """
  Convert to map for serialization
  """
  defdelegate serialize_blueprint(blueprint), to: Blueprints

  @doc """
  Load a blueprint from a file.

  Used for file upload as phoenix write into temp file
  """
  defdelegate update_blueprint_from_file(blueprint, path), to: Blueprints

  @doc """
  Load variables and index them
  """
  defdelegate load_variables(blueprint), to: Blueprints

  @doc """
  Load deductions and arrange them, load_variables MUST be called first
  """
  defdelegate load_deductions(blueprint), to: Blueprints

  @doc """
  Create variable with attributes
  """
  defdelegate create_variable(parent, attrs), to: Variables

  @doc """
  Update variable with attributes
  """
  defdelegate update_variable(var, attrs), to: Variables

  @doc """
  Delete variable (will error if variable is in use)
  """
  defdelegate delete_variable(var), to: Variables

  @doc """
  Move variable to new parent
  """
  defdelegate move_variable(var, new_parent), to: Variables

  defstruct blueprint: nil, compiled_ast: nil, state: nil, info: nil

  @doc """
  Compile blueprint into processor
  """
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

  @doc """
  Reun processor with given input
  """
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
