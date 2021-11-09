defmodule VacEngine.Processor do
  @moduledoc """
  The Processor module is responsible for generating and executing functions
  to compute API output from API input.


  ## Processors

  ### Process input

  The role of the processor is to compute the output variables of an api call
  based on the input variables. Such a computation is made using the `run/2`
  function:

      {:ok, %{output: state.output, input: state.input}} = Processor.run(processor, input)

  ### Build a processor

  A processor is an in memory function, compiled from a description
  called "Blueprint". The procedure to obtain a blueprint is described
  in the "Blueprint edition" and "Blueprint export/import" sections below.

  The compilation from a blueprint to a processor is made using the
  `Processor.compile_blueprint/1` function:

      {:ok, processor} = Processor.compile_blueprint(blueprint)


  ## Blueprint

  A blueprint is an ecto model living in the database and attached to
  a workspace.
  It has the following composition:

             _ Blueprint _
            |             |
          0..n           0..n
            |             |
      Variables         Deductions
      (input, output      |
      intermediate)      0..n
                          |
                      _ Branches _
                     |            |
                    0..n         1..n
                     |            |
                Condition    Assignment
                     |            |
                     1            1
                     |            |
                Expession    Expression

  #### variables

  Variables describe the values the processor can receive (input),
  return (output) or compute as intermediary values.
  They are attached to a type, a position in the input or output
  and some other properties like optional/required.

  #### deductions

  Deductions are descriptions of how intermediary and output variables
  should be computed. They are built as tables whose columns correspond
  to the involved variables (assigned one or ones playing role in conditions)
  and the rows to subsidiary conditions/assignement branches (if the conditions
  of the first branch are not met, the second branch is tested, and so on).

  #### branches

  A (possibly empty) set of conditions on certain variables linked with
  an assignation to other (or same) variables.

  #### condition

  An expression describing when the condition is met based on
  it's column's variable.

  #### assignment

  An expression describing the value the column's variable should take
  in case the branch conditions are met.

  #### expression

  Either a constant, a variable or a function involving other expressions
  that can be computed based on the current variables state. Condition
  expressions return nullable booleans, assignment expression return a nullable
  value of the type of the column's variable.

  ## Blueprint manipulation

  ### Creation and import

  Blueprints can be created using the `create_blueprint/2` function.
  This function requires you to provide attributes for the blueprint.

  Update to the blueprint such as modifying name or description can be made
  using the `update_blueprint/2` function.

  Populating a whole blueprint can done by importing a blueprint from a
  .json file definition. This is done using the `update_blueprint_from_file/2`
  function.

  ### Manipulation

  A set of functions allow you to directly load and update variables
  and deductions.
  """
  alias VacEngine.Processor
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Blueprints
  alias VacEngine.Processor.Compiler
  alias VacEngine.Processor.State
  alias VacEngine.Processor.Variables
  alias VacEngine.Processor.Info

  @doc """
  List blueprint
  """
  defdelegate list_blueprints(queries \\ & &1), to: Blueprints

  @doc """
  Get a blueprint with id, raise if not found.
  """
  defdelegate get_blueprint!(blueprint_id, queries \\ & &1), to: Blueprints

  defdelegate filter_blueprints_by_workspace(query, workspace), to: Blueprints

  defdelegate filter_blueprints_by_query(query, search), to: Blueprints

  defdelegate limit_blueprints(query, limit), to: Blueprints

  @doc """
  Load variables and index them
  """
  defdelegate load_blueprint_variables(query), to: Blueprints

  @doc """
  Load deductions and arrange them, load_blueprint_variables MUST be called first
  """
  defdelegate load_blueprint_full_deductions(query), to: Blueprints

  defdelegate load_blueprint_active_publications(query), to: Blueprints

  defdelegate load_blueprint_publications(query), to: Blueprints

  @doc """
  Create a blueprint with the given attributes
  TODO describe attributes
  """
  defdelegate create_blueprint(workspace, attrs), to: Blueprints

  @doc """
  Delete blueprint (will error if used)
  """
  defdelegate delete_blueprint(blueprint), to: Blueprints

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

  @doc """
  Convert to map for serialization
  """
  defdelegate serialize_blueprint(blueprint), to: Blueprints

  @doc """
  Load a blueprint from a file.

  Used for file upload as phoenix write into temp file
  """
  defdelegate update_blueprint_from_file(blueprint, path), to: Blueprints

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
  Run processor with given input
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
