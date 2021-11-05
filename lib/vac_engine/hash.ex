defmodule VacEngine.Hash do
  @moduledoc """
  Hash utilities
  """

  @doc """
  Human readable sha256 hash
  """
  def hash_string(str) do
    :crypto.hash(:sha256, str)
    |> Base24.encode24()
  end
end
