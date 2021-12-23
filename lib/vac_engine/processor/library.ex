defmodule VacEngine.Processor.Library do
  @moduledoc """
  Blueprint functions library queries
  """
  use VacEngine.Processor.Library.Import

  @doc """
  Check if function exists
  """
  def has_function?(fname, arity) do
    functions()
    |> Map.get(fname, %{})
    |> Map.get(arity)
    |> is_map()
  end

  @doc """
  Get signature of function
  """
  def get_signature(fname, arg_types) do
    arity = length(arg_types)

    functions()
    |> Map.get(fname, %{})
    |> Map.get(arity)
    |> case do
      nil ->
        nil

      %{signatures: sigs} ->
        sigs
        |> Enum.find(fn
          {^arg_types, _} -> true
          {args, _} -> args_match?(args, arg_types)
          _ -> false
        end)
    end
  end

  @doc """
  Look for candidates, i.e. functions whose signature match the given argument
  types.
  """
  def candidates(request) do
    request =
      Map.get(request, :name)
      |> case do
        s when is_binary(s) ->
          String.split(s, "/")
          |> case do
            [name, arity] ->
              Map.merge(request, %{
                name: String.to_existing_atom(name),
                arity: String.to_integer(arity)
              })

            [name] ->
              Map.put(request, :name, String.to_existing_atom(name))
          end

        _name ->
          request
      end

    functions()
    |> filter_name(Map.get(request, :name))
    |> flatten_funcs()
    |> filter_arity(Map.get(request, :arity))
    |> filter_signatures(
      Map.get(request, :arguments),
      Map.get(request, :return)
    )
    |> Enum.sort()
  end

  defp filter_name(funcs, nil), do: funcs

  defp filter_name(funcs, name) do
    %{
      name => Map.get(funcs, name)
    }
  end

  defp flatten_funcs(funcs) do
    funcs
    |> Map.values()
    |> Enum.map(fn
      nil -> []
      map -> Map.values(map)
    end)
    |> List.flatten()
  end

  defp filter_arity(funcs, nil), do: funcs

  defp filter_arity(funcs, arity) do
    funcs
    |> Enum.filter(fn f ->
      f.arity == arity
    end)
  end

  defp filter_signatures(funcs, nil, nil), do: funcs

  defp filter_signatures(funcs, args, ret) do
    funcs
    |> Enum.map(fn f ->
      f.signatures
      |> Enum.filter(fn {sig_args, _sig_ret} ->
        args_partial_match?(sig_args, args)
      end)
      |> Enum.filter(fn {_sig_args, sig_ret} ->
        ret == nil || ret == :any || sig_ret == ret
      end)
      |> then(fn sigs ->
        Map.put(f, :signatures, sigs)
      end)
    end)
    |> Enum.filter(fn f ->
      Enum.count(f.signatures) > 0
    end)
  end

  defp args_match?(sig_args, req_args)
       when length(sig_args) != length(req_args),
       do: false

  defp args_match?(sig_args, req_args) do
    Enum.zip(sig_args, req_args)
    |> Enum.all?(fn {sig_args, req_args} ->
      sig_args == req_args || sig_args == :any
    end)
  end

  defp args_partial_match?(sig_args, req_args)
       when length(sig_args) < length(req_args),
       do: false

  defp args_partial_match?(_sig_args, nil), do: true

  defp args_partial_match?(sig_args, req_args) do
    req_args
    |> Enum.with_index()
    |> Enum.all?(fn {t, idx} ->
      s = Enum.at(sig_args, idx)
      t == :any || s == :any || t == s
    end)
  end
end
