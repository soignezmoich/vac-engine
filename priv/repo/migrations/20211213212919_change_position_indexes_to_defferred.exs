defmodule VacEngine.Repo.Migrations.ChangePositionIndexesToDefferred do
  use Ecto.Migration

  def up do
    execute("DROP INDEX deductions_position_blueprint_id_index")
    execute("ALTER TABLE deductions
        ADD CONSTRAINT deductions_blueprint_id_position_index unique(blueprint_id, position)
        DEFERRABLE INITIALLY DEFERRED;")

    execute("DROP INDEX branches_position_deduction_id_index")
    execute("ALTER TABLE branches
        ADD CONSTRAINT branches_deduction_id_position_index unique(deduction_id, position)
        DEFERRABLE INITIALLY DEFERRED;")

    execute("DROP INDEX columns_position_deduction_id_index")
    execute("ALTER TABLE columns
        ADD CONSTRAINT columns_deduction_id_position_index unique(deduction_id, position)
        DEFERRABLE INITIALLY DEFERRED;")

    execute("DROP INDEX bindings_position_expression_id_index")
    execute("ALTER TABLE bindings
        ADD CONSTRAINT bindings_expression_id_position_index unique(expression_id, position)
        DEFERRABLE INITIALLY DEFERRED;")

    execute("DROP INDEX bindings_elements_position_binding_id_index")
    execute("ALTER TABLE bindings_elements
        ADD CONSTRAINT bindings_elements_binding_id_position_index unique(binding_id, position)
        DEFERRABLE INITIALLY DEFERRED;")
  end
end
