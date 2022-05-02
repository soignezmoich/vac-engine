defmodule VacEngine.Simulation do
  @moduledoc """

  Provides the model for the blueprint simulation. Simulation is used
  to assess whether a ruleset meets business requirements.

  A blueprint simulation is a collection of input/output definitions. The output
  corresponds to the expected outcome of the blueprint for the given input.

  ## Simulation runner

  The input descriptions are processed a case runner (similar to the main processor)
  in order to determine if the corresponding output expectations are met.

  ## Stacks, layers, cases

  The description passed to the runner is actually a "stack" of simple descriptions
  called "cases" where the higher case's values overwrite the lower case's ones.
  Cases are refenced as "layer" in the "stack" and may be referenced in several stacks.
  Only input is composed this way. Lower cases are not intended to describe output.

  ## Two-layers "Basic stacks" and "Templates"

  In the current implementation of the simulation. Stacks are limited to two level. The
  bottom layer is called a "Template" where the top one is called a "Runnable case".

  ## Blueprint templates and basic stacks

  Each blueprint simulation has a collection of templates (a many to many relation between
  cases and blueprints) that can be used as bottom layer cases. Each simulation also has
  a collection fo "Basic stacks", each containing a runnable case and optionally a template.
  The editor allows to pick the template of the basic cases among the simulation's templates,
  but technically, a template can be any case of the workspace.

  ## Case sharing

  Blueprints can share cases. This automatically occurs when a blueprint is duplicated, but
  not when a blueprint is exported and reimported where each case is duplicated.

  When cases are shared, they can be modified at one for every blueprint. This is useful when
  you want to fix an error.



  ## Workspace cases collections



  Cases

  Cases are grouped in a multi-layer stack. Each layer is a single case.

  The content of a case can be used as a base for another case, forming a *stack*
  (technically, even a single case is part of a stack).

  The basic stack is a two-layered stack (used as the only existing stack structure)

  Cases are created workspace-wide whereas case stacks are limited to the blueprint
  scope. This structure allows to share cases among several blueprints.
  """

  alias VacEngine.Simulation.BulkImportation
  alias VacEngine.Simulation.Cases
  alias VacEngine.Simulation.InputEntries
  alias VacEngine.Simulation.OutputEntries
  alias VacEngine.Simulation.Runners
  alias VacEngine.Simulation.Settings
  alias VacEngine.Simulation.Stacks
  alias VacEngine.Simulation.Templates
  alias VacEngine.Simulation.SimpleStacks
  alias VacEngine.SimulationHelpers

  ##################
  # CASE FUNCTIONS #
  ##################

  @doc """
  Sets whether the case expects an error to occur (mostly when the complete element is not used).
  """
  defdelegate set_expect_run_error(kase, expect_run_error), to: Cases

  ###################
  # STACK FUNCTIONS #
  ###################

  @doc """
  Creates a new stack with an empty runnable case and no template case.
  """
  defdelegate create_blank_stack(blueprint, name), to: Stacks

  @doc """
  Creates a new stack using the given attributes.
  """
  defdelegate create_stack(blueprint, attrs \\ %{}), to: Stacks

  @doc """
  Deletes the stack with the given id. Layers are also deleted. Cases not.
  """
  defdelegate delete_stack(stack_id), to: Stacks

  @doc """
  Get the first stack associated to the given blueprint.
  """
  defdelegate get_first_stack(blueprint), to: Stacks

  @doc """
  Retrieve a stack corresponding to the given id.
  """
  defdelegate get_stack(stack_id), to: Stacks

  @doc """
  Retrieve a stack corresponding to the given id (throw! version).
  """
  defdelegate get_stack!(stack_id, queries), to: Stacks

  @doc """
  Retrieve all the stack names for the given blueprint.

  Typically used to build the list of available stacks.
  """
  defdelegate get_stack_names(blueprint), to: Stacks

  @doc """
  Get all stacks for the given blueprint.
  """
  defdelegate get_stacks(blueprint), to: Stacks

  @doc """
  Add the case entries (input and output) to the stacks retrieved
  by the given query.
  """
  defdelegate load_stack_layers_case_entries(query), to: Stacks

  @doc """
  Add the setting attribute to the stacks retrieved by the given
  query.
  """
  defdelegate load_stack_setting(query), to: Stacks

  @doc """
  Get the blueprint name and ids that share the runnable case of
  the given simple (two-layer) stack.
  """
  defdelegate get_blueprints_sharing_runnable_case(stack), to: SimpleStacks

  #######################
  # SIMULATION SETTINGS #
  #######################

  defdelegate get_setting(blueprint), to: Settings

  defdelegate create_setting(blueprint), to: Settings

  defdelegate update_setting(setting, options), to: Settings

  defdelegate validate_setting(changeset), to: Settings

  #############
  # TEMPLATES #
  #############

  defdelegate cases_using_template(template), to: Templates

  defdelegate create_blank_template(blueprint, name), to: Templates

  defdelegate delete_template(template_id), to: Templates

  defdelegate fork_template_case(template, name), to: Templates

  defdelegate get_template(template_id), to: Templates

  defdelegate get_templates(blueprint), to: Templates

  defdelegate get_template_cases(blueprint), to: Templates

  defdelegate get_template_names(blueprint), to: Templates

  @doc """
  Returns the name and ids of the blueprints with which the case is shared.
  """
  defdelegate get_blueprints_sharing_template_case(template), to: Templates

  ########################
  # INPUT/OUTPUT ENTRIES #
  ########################

  defdelegate create_input_entry(kase, key, value \\ "-"), to: InputEntries

  defdelegate delete_input_entry(input_entry), to: InputEntries

  defdelegate update_input_entry(input_entry, value), to: InputEntries

  defdelegate validate_input_entry(changeset, variable), to: InputEntries

  defdelegate create_blank_output_entry(kase, key, variable), to: OutputEntries

  defdelegate delete_output_entry(output_entry), to: OutputEntries

  defdelegate set_expected(entry, expected), to: OutputEntries

  defdelegate toggle_forbidden(entry, forbidden), to: OutputEntries

  #############################
  # BASIC (TWO LAYERS) STACKS #
  #############################

  defdelegate delete_stack_template(stack), to: SimpleStacks

  defdelegate get_stack_runnable_case(stack), to: SimpleStacks

  defdelegate get_stack_template_case(stack), to: SimpleStacks

  defdelegate set_stack_template(stack, template_case_id), to: SimpleStacks

  defdelegate fork_runnable_case(stack, name), to: SimpleStacks

  ###################
  # SIMULATION JOBS #
  ###################

  defdelegate queue_job(job), to: Runners

  ###########
  # HELPERS #
  ###########

  defdelegate variable_default_value(type, enum), to: SimulationHelpers

  ###############
  # IMPORTATION #
  ###############

  defdelegate import_all_cases(path), to: BulkImportation
end
