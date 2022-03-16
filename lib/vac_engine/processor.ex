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

  ## Schemas

  Below, the ecto schemas available in the Processor module.

  #### Assignment

  A variable assignment in the branch of a bluprint deduction.

  #### AstType

  Ecto type for AST serialization to the database.

  Allows to store tuples as JSON.

  #### BindingElement

  An expression binding element.

  #### Binding

  An expression binding.

  #### Blueprint

  A blueprint describing a full processor.

  #### Branch

  A deduction branch.

  #### Column

  A deduction column (a structuration feature that has no effect when the
  processor runs on an input.)

  #### Condition

  A condition in a branch.

  #### Deduction

  A blueprint deduction.

  #### Expression

  Expressions can be found in conditions, assignments or variable default values.

  #### ListType

  Ecto type to allow storing a list in a json field.

  #### Variable

  A blueprint variable.

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
  defdelegate list_blueprints(queries \\ & &1), to: Blueprints.Load

  @doc """
  Get a blueprint with id, raise if not found.
  """
  defdelegate get_blueprint!(blueprint_id, queries \\ & &1), to: Blueprints.Load

  @doc """
  Get a blueprint with id, nil if not found.
  """
  defdelegate get_blueprint(blueprint_id, queries \\ & &1), to: Blueprints.Load

  @doc """
  Apply a workspace scope to a blueprint query
  """
  defdelegate filter_blueprints_by_workspace(query, workspace),
    to: Blueprints.Load

  @doc """
  Filter accessible blueprints with role
  """
  defdelegate filter_accessible_blueprints(query, role), to: Blueprints.Load

  @doc """
  Load blueprint workspace
  """
  defdelegate load_blueprint_workspace(query), to: Blueprints.Load

  @doc """
  Load variables and index them
  """
  defdelegate load_blueprint_variables(query), to: Blueprints.Load

  @doc """
  Load deductions and arrange them, load_blueprint_variables MUST be called first
  """
  defdelegate load_blueprint_full_deductions(query), to: Blueprints.Load

  @doc """
  Load simulation elements associated with the blueprint (settings, templates
  and stacks).
  If the `with_cases?` parameter is set to true, the associated cases
  (with input/output entries) are also loaded.
  """
  defdelegate load_blueprint_simulation(query, with_cases?), to: Blueprints.Load

  @doc """
  Get the fully preloaded version of the blueprint with the given id.
  If with cases is set to true, it also includes related cases.
  Otherwise, only stacks, layers and templates are preloaded.
  """
  defdelegate get_full_blueprint!(query, with_cases?), to: Blueprints.Load

  @doc """
  Load active publications in the given blueprint query.
  """
  defdelegate load_blueprint_active_publications(query), to: Blueprints.Load

  @doc """
  Load inactive publications in the give blueprint query.
  """
  defdelegate load_blueprint_inactive_publications(query), to: Blueprints.Load

  @doc """
  Load all publications in the given blueprint query.
  """
  defdelegate load_blueprint_publications(query), to: Blueprints.Load

  @doc """
  Get the version of the given blueprint or blueprint id.
  """
  defdelegate blueprint_version(blueprint_or_id), to: Blueprints.Load

  @doc """
  Convert to map for serialization
  """
  defdelegate serialize_blueprint(blueprint), to: Blueprints.Load

  @doc """
  Create a blueprint with the given attributes
  TODO describe attributes
  """
  defdelegate create_blueprint(workspace, attrs), to: Blueprints.Save

  @doc """
  Delete blueprint (will error if used)
  """
  defdelegate delete_blueprint(blueprint), to: Blueprints.Save

  @doc """
  Cast attributes into a changeset
  Only root attributes are supported (no variables or deductions)
  """
  defdelegate change_blueprint(blueprint, attrs \\ %{}), to: Blueprints.Save

  @doc """
  Update a blueprint with attributes
  """
  defdelegate update_blueprint(blueprint, attrs), to: Blueprints.Save

  @doc """
  Load a blueprint from a file.

  Used for file upload as phoenix write into temp file
  """
  defdelegate update_blueprint_from_file(blueprint, path), to: Blueprints.Save

  @doc """
  Check whether a blueprint is readonly
  """
  defdelegate blueprint_readonly?(blueprint), to: Blueprints.Misc

  @doc """
  Duplicate the given blueprint in it's workspace. If the duplication succeeds
  it returns:
  ```
  {:ok, new_blueprint}
  ```
  Otherwise it returns:
  {:error, error_message}
  """
  defdelegate duplicate_blueprint(blueprint), to: Blueprints.Misc

  @doc """
  Create variable with attributes
  """
  defdelegate create_variable(parent, attrs), to: Variables

  @doc """
  Change variable with attributes (no children, used for form validation)
  """
  defdelegate change_variable(var, attrs), to: Variables

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
  Check if variable is used (expensive, will hit DB)
  """
  defdelegate variable_used?(var), to: Variables

  alias VacEngine.Processor.Deductions

  defdelegate create_deduction(blueprint, attrs \\ %{}), to: Deductions
  defdelegate delete_deduction(deduction), to: Deductions
  defdelegate change_deduction(deduction, attrs \\ %{}), to: Deductions
  defdelegate update_deduction(deduction, attrs), to: Deductions
  defdelegate create_branch(deduction, attrs \\ %{}), to: Deductions
  defdelegate delete_branch(branch), to: Deductions
  defdelegate change_branch(branch, attrs \\ %{}), to: Deductions
  defdelegate update_branch(branch, attrs), to: Deductions
  defdelegate create_column(blueprint, deduction, attrs), to: Deductions
  defdelegate change_column(column, attrs \\ %{}), to: Deductions
  defdelegate update_column(column, attrs), to: Deductions
  defdelegate delete_column(column), to: Deductions

  defdelegate update_cell(ast, blueprint, branch, column, attrs \\ %{}),
    to: Deductions

  defdelegate delete_cell(branch, column), to: Deductions

  alias VacEngine.Processor.Advisor

  defdelegate blueprint_stats(blueprint), to: Advisor
  defdelegate blueprint_issues(blueprint), to: Advisor
  defdelegate autofix_blueprint(blueprint), to: Advisor

  defstruct blueprint: nil, compiled_module: nil, state: nil, info: nil

  @doc """
  Compile blueprint into processor
  """
  def compile_blueprint(blueprint, opts \\ [])

  def compile_blueprint(%Blueprint{} = blueprint, opts) do
    with {:ok, mod} <- Compiler.compile_blueprint(blueprint, opts),
         {:ok, info} <- Info.describe(blueprint),
         {:ok, state} <- State.new(blueprint.variables) do
      {:ok,
       %Processor{
         compiled_module: mod,
         state: state,
         blueprint: blueprint,
         info: info
       }}
    else
      {:error, err} ->
        {:error, "cannot compile blueprint: #{err}"}
    end
  end

  def compile_blueprint(nil, _opts) do
    {:error, "no blueprint"}
  end

  def compile_blueprint(_, _opts) do
    {:error, "invalid blueprint"}
  end

  @doc """
  Run processor with given input
  """
  def run(%Processor{} = processor, input, env \\ %{}) do
    with {:ok, state} <- State.map_input(processor.state, input),
         {:ok, state} <- State.map_env(state, env),
         state <- apply(processor.compiled_module, :run, [state]),
         {:ok, state} <- State.finalize_output(state) do
      {:ok, state}
    else
      {:error, msg} ->
        {:error, msg}
    end
  end

  @doc """
  Flush compiled processor
  """
  def flush_processor(%Processor{} = processor) do
    :code.delete(processor.compiled_module)
    :code.purge(processor.compiled_module)
  end

  def list_compiled_blueprint_modules() do
    :code.all_loaded()
    |> Enum.filter(fn {mod, _} -> "#{mod}" =~ ~r{^Elixir} end)
    |> Enum.map(fn {mod, _} -> Module.split(mod) end)
    |> Enum.filter(fn
      ["VacEngine", "Processor", "BlueprintCode", _ | _] ->
        true

      _ ->
        false
    end)
    |> Enum.map(&Module.concat/1)
  end
end
