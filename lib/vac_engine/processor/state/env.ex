defmodule VacEngine.Processor.State.Env do
  @moduledoc """
  Processor state runtime environment
  """

  import VacEngine.EnumHelpers
  alias VacEngine.Processor.Convert
  alias VacEngine.Processor.State

  @doc """
  Parse `env` and map content into internal env
  """
  def map_env(%State{} = state, env) do
    now =
      get_mixed?(env, :now)
      |> case do
        nil -> NaiveDateTime.utc_now()
        str -> Convert.parse_datetime(str)
      end

    state = %{state | env: %{now: now}}

    {:ok, state}
  catch
    {_code, msg} ->
      {:error, msg}
  end
end
