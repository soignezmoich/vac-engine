defmodule VacEngine.Simulation do
  @moduledoc """
  Provides the model for the blueprint simulation. Simulation is used
  to assess whether a ruleset meets business requirements.

  Simulation is based on *cases* that describe the expected output for a given
  input.

  The content of a case can be used as a base for another case, forming a *stack*
  (technically, even a single case is part of a stack).

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
  alias VacEngine.Simulation.BasicStacks
  alias VacEngine.SimulationHelpers


  ##################
  # CASE FUNCTIONS #
  ##################

  defdelegate filter_cases_by_workspace(query, workspace), to: Cases

  defdelegate get_case(case_id, queries), to: Cases

  defdelegate get_case!(case_id, queries), to: Cases

  defdelegate list_cases(queries), to: Cases

  defdelegate set_expect_run_error(kase, expect_run_error), to: Cases


  ###################
  # STACK FUNCTIONS #
  ###################

  defdelegate create_blank_stack(blueprint, name), to: Stacks

  defdelegate create_stack(blueprint, attrs \\ %{}), to: Stacks

  defdelegate delete_stack(stack_id), to: Stacks

  defdelegate filter_stacks_by_blueprint(query, blueprint), to: Stacks

  defdelegate get_first_stack(blueprint), to: Stacks

  defdelegate get_stack(stack_id), to: Stacks

  defdelegate get_stack(stack_id, queries), to: Stacks

  defdelegate get_stack!(stack_id, queries), to: Stacks

  defdelegate get_stack_names(blueprint), to: Stacks

  defdelegate get_stacks(blueprint), to: Stacks

  defdelegate list_stacks(queries), to: Stacks

  defdelegate load_stack_layers(query), to: Stacks

  defdelegate load_stack_layers_case_entries(query), to: Stacks

  defdelegate load_stack_setting(query), to: Stacks


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

  defdelegate get_template(template_id), to: Templates

  defdelegate get_templates(blueprint), to: Templates

  defdelegate get_template_names(blueprint), to: Templates

  defdelegate create_blank_template(blueprint, name), to: Templates

  defdelegate delete_template(template_id), to: Templates


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

  defdelegate delete_stack_template(stack), to: BasicStacks

  defdelegate get_stack_runnable_case(stack), to: BasicStacks

  defdelegate get_stack_template_case(stack), to: BasicStacks

  defdelegate set_stack_template(stack, template_case_id), to: BasicStacks


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
