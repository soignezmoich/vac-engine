defmodule VacEngine.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :vac_engine,
    adapter: Ecto.Adapters.Postgres
end
