defmodule VacEngine.Repo do
  use Ecto.Repo,
    otp_app: :vac_engine,
    adapter: Ecto.Adapters.Postgres
end
