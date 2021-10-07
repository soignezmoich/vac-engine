defmodule VacEngine.Processor.Expression do
  defstruct ast: nil

  alias VacEngine.Processor.Libraries
  alias VacEngine.Processor.Expression

  defmacro expr(ex) do
    quote bind_quoted: [ex: Macro.escape(ex)] do
      {:ok, e} = Expression.new(ex)
      e
    end
  end

  def new(data) do
    ast = sanitize!(data)

    {:ok, %Expression{ast: ast}}
  catch
    {_code, msg} ->
      {:error, msg}
  end

  def sanitize!({f, m, args}) when is_list(args) and is_binary(f) do
    fname = String.to_existing_atom(f)
    sanitize!({fname, m, args})
  catch
    _ ->
      throw({:undefined, "undefined function #{f}/#{length(args)}"})
  end

  def sanitize!({:@, m, args}), do: sanitize!({:var, m, args})

  def sanitize!({f, m, args}) when is_atom(f) and is_list(args) do
    ari = length(args)

    unless function_exported?(Libraries, f, ari) do
      throw({:undefined, "undefined function #{f}/#{ari}"})
    end

    m =
      if Keyword.keyword?(m) do
        Keyword.take(m, [:signature])
      else
        []
      end

    {f, m, Enum.map(args, &sanitize!/1)}
  end

  def sanitize!({f, _m, args}) when not is_list(args) do
    to_string(f)
  end

  def sanitize!(i) when is_nil(i), do: i
  def sanitize!(i) when is_number(i), do: i
  def sanitize!(b) when is_boolean(b), do: b
  def sanitize!(var) when is_atom(var), do: sanitize!(to_string(var))

  def sanitize!(var) when is_binary(var) do
    Regex.replace(~r/[^a-zA-Z0-9_]/, var, "_")
  end

  def sanitize!(list) when is_list(list) do
    Enum.map(list, &sanitize!/1)
  end

  def sanitize!(_expr) do
    throw({:invalid_expression, "invalid expression"})
  end

  def serialize(%Expression{ast: ast}) do
    {:ok, ast_to_json(ast)}
  end

  def deserialize(json) do
    # TODO limit json size
    ast =
      json
      |> json_to_ast!()
      |> sanitize!()

    {:ok, %Expression{ast: ast}}
  catch
    {_code, msg} ->
      {:error, msg}
  end

  defp ast_to_json({l, m, r}) do
    m =
      Keyword.get(m, :signature)
      |> case do
        {args, ret} when is_list(args) ->
          args =
            args
            |> Enum.map(&to_string/1)

          ret = to_string(ret)
          sig = [args, ret]
          %{"signature" => sig}

        nil ->
          %{}
      end

    %{
      "l" => to_string(l),
      "m" => m,
      "r" => Enum.map(r, &ast_to_json/1)
    }
  end

  defp ast_to_json(e), do: e

  defp json_to_ast!(%{"l" => l, "m" => m, "r" => r}) do
    m =
      Map.get(m, "signature")
      |> case do
        [[_ | _] = args, ret] ->
          if length(args) > 32 do
            throw({:invalid_signature, "invalid signature"})
          end

          args =
            args
            |> Enum.map(&String.to_existing_atom/1)

          ret = String.to_existing_atom(ret)
          sig = {args, ret}
          [signature: sig]

        nil ->
          []
      end

    l = String.to_existing_atom(l)

    {l, m, Enum.map(r, &json_to_ast!/1)}
  end

  defp json_to_ast!(%{"l" => l, "r" => r}) do
    {l, [], Enum.map(r, &json_to_ast!/1)}
  end

  defp json_to_ast!(e), do: e
end
