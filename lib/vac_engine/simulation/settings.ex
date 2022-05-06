defmodule VacEngine.Simulation.Settings do
  @moduledoc false

  import Ecto.Changeset
  import Ecto.Query
  import VacEngine.EctoHelpers

  alias Ecto.Changeset
  alias VacEngine.Repo
  alias VacEngine.Simulation.Setting

  def create_setting(blueprint) do
    env_now =
      Timex.parse("2000-01-01", "{YYYY}-{0M}-{0D}")
      |> case do
        {:ok, r} -> Timex.to_datetime(r)
        _ -> nil
      end

    %Setting{
      workspace_id: blueprint.workspace_id,
      blueprint_id: blueprint.id,
      env_now: env_now
    }
    |> change(%{})
    |> Repo.insert()
  end

  def get_setting(blueprint) do
    from(s in Setting,
      where: s.blueprint_id == ^blueprint.id
    )
    |> Repo.one()
  end

  def update_setting(setting, env_now: env_now) do
    setting
    |> cast(%{"env_now" => env_now}, [:env_now])
    |> validate_setting()
    |> Repo.update()
  end

  def validate_setting(%Changeset{} = changeset) do
    changeset
    |> validate_required([:env_now])
    |> validate_type(:env_now, :datetime)
  end
end
