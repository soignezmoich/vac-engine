defmodule VacEngine.PipeHelpers do
  @moduledoc false

  @doc """
  Wrap into ok tuple
  """
  def ok(val) do
    {:ok, val}
  end

  def noreply(val) do
    {:noreply, val}
  end

  @doc """
  Wrap into tuple pair
  """
  def pair(val, res) do
    {res, val}
  end

  @doc """
  Wrap into tuple rpair
  """
  def rpair(val, res) do
    {val, res}
  end

  @doc """
  Tap only if ok tuple
  """
  def tap_ok(result, fun) do
    then_ok(result, fun)
    result
  end

  @doc """
  Tap only if value match
  """
  def tap_on(result, value, fun) do
    then_on(result, value, fun)
    result
  end

  @doc """
  Then only if ok tuple
  """
  def then_ok({:ok, ok_val} = _result, fun) do
    fun
    |> Function.info()
    |> Keyword.get(:arity)
    |> case do
      0 -> fun.()
      1 -> fun.(ok_val)
      _ -> raise "then_ok function arity can only be 0 or 1"
    end
  end

  def then_ok(result, _fun), do: result

  @doc """
  Then only if value match
  """
  def then_on(value, value, fun) do
    fun
    |> Function.info()
    |> Keyword.get(:arity)
    |> case do
      0 -> fun.()
      1 -> fun.(value)
      _ -> raise "then_on function arity can only be 0 or 1"
    end
  end

  def then_on(result, _value, _fun), do: result

  @doc """
  Put a message on the terminal then pass the input value.
  """
  def puts_then(value, message) do
    IO.puts(message)
    value
  end

  @doc """
  Inspect the element returned by a callback function
  then pass the input value.
  """
  def func_inspect(value, fnc) do
    # credo:disable-for-next-line Credo.Check.Warning.IoInspect
    IO.inspect(fnc.(value))
    value
  end

  @doc """
  Same as above, with a label on the previous line.
  """
  def func_inspect(value, fnc, label) do
    IO.puts(label)
    # credo:disable-for-next-line Credo.Check.Warning.IoInspect
    IO.inspect(fnc.(value))
    value
  end
end
