defmodule VacEngine.Hash do
  def hash_string(str) do
    :crypto.hash(:sha256, str)
    |> Base24.encode24()
  end
end
