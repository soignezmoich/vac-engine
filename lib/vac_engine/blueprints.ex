defmodule VacEngine.Blueprints do
  import Ecto.Query
  alias VacEngine.Repo
  alias VacEngine.Blueprints.Blueprint
  alias VacEngine.Accounts.Workspace

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

end
