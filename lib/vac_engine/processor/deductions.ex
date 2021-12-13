defmodule VacEngine.Processor.Deductions do
  @moduledoc false

  import Ecto.Query
  alias Ecto.Multi
  alias Ecto.Changeset
  alias VacEngine.Repo
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Deduction
  import VacEngine.EctoHelpers

  def create_deduction(%Blueprint{} = blueprint, attrs) do
    Deduction.changeset(
      %Deduction{
        blueprint_id: blueprint.id,
        workspace_id: blueprint.workspace_id
      },
      attrs
    )
    |> Repo.insert()
  end

  def update_deduction(%Deduction{} = deduction, attrs) do
    Deduction.changeset(deduction, attrs)
    |> Repo.update()
  end

  def delete_deduction(%Deduction{} = deduction) do
    dec_query =
      from(r in Deduction,
        where:
          r.position >= ^deduction.position and
            r.blueprint_id == ^deduction.blueprint_id
      )

    Multi.new()
    |> Multi.update_all(:decrement, dec_query, inc: [position: -1])
    |> Multi.delete(:deduction, deduction)
    |> transaction(:deduction)
  end
end
