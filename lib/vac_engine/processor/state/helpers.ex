defmodule VacEngine.Processor.State.Helpers do
  @moduledoc false

  require VacEngine.Processor.Meta
  alias VacEngine.Processor.Meta

  def cast_path(name) do
    name
    |> Meta.cast_path()
    |> case do
      {:ok, path} ->
        path

      {_, err} ->
        throw({:invalid_path, err})
    end
  end

  def get_type(nil), do: nil
  def get_type(var), do: var.type
end
