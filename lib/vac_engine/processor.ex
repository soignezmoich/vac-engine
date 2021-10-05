defmodule VacEngine.Processor do
  import Ecto.Query
  alias VacEngine.Repo
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Accounts.Workspace
  alias VacEngine.Processor.Compiler
  alias VacEngine.Processor.State
  alias VacEngine.Processor

  def create_blueprint(%Workspace{} = workspace, attrs) do
    %Blueprint{workspace_id: workspace.id}
    |> Blueprint.changeset(attrs)
    |> Repo.insert()
  end

  def change_blueprint(blueprint_or_changeset, attrs) do
    blueprint_or_changeset
    |> Blueprint.changeset(attrs)
  end

  def update_blueprint(blueprint_or_changeset, attrs) do
    blueprint_or_changeset
    |> change_blueprint(attrs)
    |> Repo.update()
  end

  def list_blueprints(%Workspace{} = workspace) do
    from(b in Blueprint,
      where: b.workspace_id == ^workspace.id,
      select: [:id, :name, :description]
    )
    |> Repo.all()
  end

  def get_blueprint!(id) do
    Repo.get!(Blueprint, id)
  end


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

    time(fn -> Compiler.eval_ast(processor.compiled_ast, state) end)
    |> case do
      {:ok, state} ->
        state = State.finalize_output(state)
        {:ok, state.output}

      err ->
        err
    end
  end

  def time(fun) do
    {time, ret} = :timer.tc(fun)

    IO.puts("Elapsed time: #{time}uSec")
    ret
  end
end
