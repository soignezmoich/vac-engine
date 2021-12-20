defmodule VacEngine.Processor.Ast do
  @moduledoc """
  Represent the blueprint "simple" AST

  Format is compatible with elixir AST
  """
  alias VacEngine.Processor.Library
  alias VacEngine.Processor.Meta

  @doc """
  Convert data to AST, sanitize any unsupported functions
  """
  def sanitize(data) do
    ast = sanitize!(data)

    {:ok, ast}
  catch
    {_code, msg} ->
      {:error, msg}
  end

  defp sanitize!({f, m, args}) when is_list(args) and is_binary(f) do
    fname = convert_atom(f)
    sanitize!({fname, m, args})
  catch
    _err ->
      throw({:undefined, "undefined function #{f}/#{length(args)}"})
  end

  defp sanitize!({:@, m, args}), do: sanitize!({:var, m, args})

  defp sanitize!({f, m, args}) when is_atom(f) and is_list(args) do
    ari = length(args)

    unless Library.has_function?(f, ari) do
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

  # Handle @name notation (args is Elixir)
  defp sanitize!({f, _m, args}) when not is_list(args) do
    to_string(f)
  end

  defp sanitize!(i) when is_nil(i), do: i
  defp sanitize!(i) when is_number(i), do: i
  defp sanitize!(b) when is_boolean(b), do: b
  defp sanitize!(var) when is_atom(var), do: sanitize!(to_string(var))

  defp sanitize!(var) when is_binary(var) do
    Regex.replace(~r/[^a-zA-Z0-9-:_]/, var, "_")
  end

  defp sanitize!(list) when is_list(list) do
    Enum.map(list, &sanitize!/1)
  end

  defp sanitize!(_expr) do
    throw({:invalid_expression, "invalid expression"})
  end

  @doc """
  Extract bindings

  This convert `{:var, [], [["foo", "bar"]]}` to
  `{:var, [], [0]}` and return `[["foo", "bar"]]` in bindings.
  """
  def extract_bindings(ast) do
    {ast, bindings} = extract_bindings!(ast, [])
    {:ok, {ast, Enum.reverse(bindings)}}
  catch
    {_code, msg} ->
      {:error, msg}
  end

  defp extract_bindings!({:var, m, [path]}, bindings) do
    path =
      path
      |> Meta.cast_path()
      |> case do
        {:ok, path} -> path
        _ -> throw({:invalid_binding, "path #{path} is not a valid binding"})
      end

    {{:var, m, [length(bindings)]}, [path | bindings]}
  end

  defp extract_bindings!({f, m, r}, bindings) when is_atom(f) and is_list(r) do
    {r, bindings} =
      r
      |> Enum.map_reduce(bindings, fn el, bindings ->
        extract_bindings!(el, bindings)
      end)

    {{f, m, r}, bindings}
  end

  defp extract_bindings!(ast, bindings) do
    {ast, bindings}
  end

  @doc """
  Insert bindings, reverse of extract_bindings(
  """
  def insert_bindings(data, bindings) do
    ast = insert_bindings!(data, bindings)
    {:ok, ast}
  catch
    {_code, msg} ->
      {:error, msg}
  end

  defp insert_bindings!({:var, m, [pos]}, bindings) do
    path = Enum.at(bindings, pos)
    {:var, m, [path]}
  end

  defp insert_bindings!({f, m, r}, bindings) when is_atom(f) and is_list(r) do
    r =
      r
      |> Enum.map(fn el ->
        insert_bindings!(el, bindings)
      end)

    {f, m, r}
  end

  defp insert_bindings!(ast, _bindings) do
    ast
  end

  @doc """
  Insert signatures, types are bindings types
  """
  def insert_signatures(data, types) do
    ast = insert_signatures!(data, types)
    {:ok, ast}
  catch
    {_code, msg} ->
      {:error, msg}
  end

  defp insert_signatures!({:var, m, [pos] = r}, bindings) do
    type = Enum.at(bindings, pos)

    if is_nil(type) do
      throw({:type_missing, "type is missing for binding at index #{pos}"})
    end

    m = Keyword.put(m, :signature, {[:name], type})
    {:var, m, r}
  end

  defp insert_signatures!({f, _m, r}, bindings)
       when is_atom(f) and is_list(r) do
    {r, arg_types} =
      r
      |> Enum.map(fn el ->
        val = insert_signatures!(el, bindings)
        {val, typeof(val)}
      end)
      |> Enum.unzip()

    Library.get_signature(f, arg_types)
    |> case do
      nil ->
        f = "#{f}/#{length(arg_types)} (#{Enum.join(arg_types, ",")})"
        throw({:signature_not_found, "signature for function #{f} not found"})

      sig ->
        {f, [signature: sig], r}
    end
  end

  defp insert_signatures!(ast, _bindings) do
    ast
  end

  defp typeof({_f, [signature: {_args, ret}], _r}), do: ret
  defp typeof(v) when is_integer(v), do: :integer
  defp typeof(v) when is_number(v), do: :number
  defp typeof(v) when is_boolean(v), do: :boolean
  defp typeof(v) when is_binary(v), do: :string

  defp typeof([h | _]) do
    "#{typeof(h)}[]" |> convert_atom()
  end

  defp typeof(v) when is_list(v) do
    throw({:empty_list, "type cannot be infered from empty list"})
  end

  defp typeof(_v) do
    throw({:unknown_type, "type cannot be infered"})
  end

  @doc """
  Serialize AST into JSON compatible format
  """
  def serialize(ast) do
    {:ok, ast_to_json(ast) |> wrap_root()}
  end

  @doc """
  Deserialize AST from JSON compatible format
  """
  def deserialize(json) do
    ast =
      json
      |> unwrap_root()
      |> json_to_ast!()
      |> sanitize!()

    {:ok, ast}
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
        [args, ret] when is_list(args) ->
          if length(args) > 32 do
            throw({:invalid_signature, "invalid signature"})
          end

          args =
            args
            |> Enum.map(&convert_atom/1)

          ret = convert_atom(ret)
          sig = {args, ret}
          [signature: sig]

        nil ->
          []
      end

    l = convert_atom(l)

    {l, m, Enum.map(r, &json_to_ast!/1)}
  end

  defp json_to_ast!(%{"l" => l, "r" => r}) do
    {l, [], Enum.map(r, &json_to_ast!/1)}
  end

  defp json_to_ast!(e), do: e

  defp wrap_root(val), do: %{"ast" => val}
  defp unwrap_root(%{"ast" => val}), do: val

  @doc """
  Describe an AST (to_string())
  """
  def describe({:var, _, [path]}) do
    "@#{Enum.join(path, ".")}"
  end

  def describe({f, _, args}) do
    args =
      args
      |> Enum.map(&describe/1)
      |> Enum.join(", ")

    "#{f}(#{args})"
  end

  def describe(ast) do
    inspect(ast)
  end

  defp convert_atom(a) when is_atom(a), do: a

  defp convert_atom(a) when is_binary(a) do
    String.to_existing_atom(a)
  rescue
    _ ->
      throw({:name_not_found, "name #{a} not found"})
  end

  defp convert_atom(_a) do
    throw({:invalid_name, "invalid name"})
  end
end
