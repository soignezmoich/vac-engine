defmodule VacEngine.Repo.Migrations.AddIndexes do
  use Ecto.Migration

  def change do
    create(index(:bindings, [:workspace_id]))
    create(index(:bindings, [:blueprint_id]))
    create(index(:bindings, [:expression_id]))
    create(index(:bindings_elements, [:workspace_id]))
    create(index(:bindings_elements, [:blueprint_id]))
    create(index(:bindings_elements, [:binding_id]))
    create(index(:bindings_elements, [:variable_id]))
    create(index(:assignments, [:workspace_id]))
    create(index(:assignments, [:blueprint_id]))
    create(index(:assignments, [:deduction_id]))
    create(index(:conditions, [:workspace_id]))
    create(index(:conditions, [:blueprint_id]))
    create(index(:conditions, [:deduction_id]))
    create(index(:branches, [:workspace_id]))
    create(index(:branches, [:blueprint_id]))
    create(index(:columns, [:workspace_id]))
    create(index(:columns, [:blueprint_id]))
    create(index(:columns, [:deduction_id]))
    create(index(:expressions, [:workspace_id]))
    create(index(:expressions, [:blueprint_id]))
    create(index(:expressions, [:column_id]))
    create(index(:expressions, [:condition_id]))
    create(index(:expressions, [:assignment_id]))
    create(index(:publications, [:workspace_id]))
    create(index(:publications, [:blueprint_id]))
    create(index(:publications, [:portal_id]))
    create(index(:variables, [:parent_id]))
  end
end
