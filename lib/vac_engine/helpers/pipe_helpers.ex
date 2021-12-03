defmodule VacEngine.PipeHelpers do
  @moduledoc """
  Helper for piping data
  """

  @doc """
  Wrap into ok tuple
  """
  def ok(val) do
    {:ok, val}
  end

  @doc """
  Tap only if ok tuple
  """
  def tap_ok({:ok, ok_val} = result, fun) do
    fun
    |> Function.info()
    |> Keyword.get(:arity)
    |> case do
      0 -> fun.()
      1 -> fun.(ok_val)
      _ -> raise "tap_ok function arity can only be 0 or 1"
    end

    result
  end

  def tap_ok(result, _fun), do: result

  @doc """
  Tap only if value match
  """
  def tap_on(value, value, fun) do
    fun
    |> Function.info()
    |> Keyword.get(:arity)
    |> case do
      0 -> fun.()
      1 -> fun.(value)
      _ -> raise "tap_on function arity can only be 0 or 1"
    end

    value
  end

  def tap_on(result, _value, _fun), do: result
end
