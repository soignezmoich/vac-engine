defmodule VacEngine.Token do
  def generate(length \\ 16) do
    :crypto.strong_rand_bytes(length) |> Base24.encode24()
  end
end
