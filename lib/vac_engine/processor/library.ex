defmodule VacEngine.Processor.Library do
  use VacEngine.Processor.Library.Import

  def has_function?(fname, arity) do
    functions()
    |> Map.get(fname, %{})
    |> Map.get(arity)
    |> is_map()
  end

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

  def candidates(args) when is_list(args) do
    candidates({args, :any})
  end

  def candidates({req_args, req_ret}) when is_list(req_args) do
    functions()
    |> Enum.reduce(%{}, fn {fname, funcs}, candidates ->
      filter_candidates(funcs, {req_args, req_ret}, fname, candidates)
    end)
    |> Map.values()
    |> Enum.sort_by(& &1.name)
  end

  def func_candidates(fname, req_args) when is_list(req_args) do
    func_candidates(fname, {req_args, :any})
  end

  def func_candidates(fname, {req_args, req_ret}) when is_list(req_args) do
    functions()
    |> Map.get(fname)
    |> filter_candidates({req_args, req_ret}, fname, %{})
    |> Map.values()
    |> Enum.sort_by(& &1.name)
  end

  defp filter_candidates(nil, _, _, _), do: %{}

  defp filter_candidates(funcs, {req_args, req_ret}, fname, candidates) do
    funcs
    |> Enum.reduce(candidates, fn {_arity, func}, candidates ->
      func.signatures
      |> Enum.reduce(candidates, fn {sig_args, sig_ret}, candidates ->
        if (req_ret == :any || req_ret == sig_ret) &&
             args_partial_match?(sig_args, req_args) do
          candidates
          |> update_in([fname], fn f ->
            (f || %{})
            |> Map.merge(Map.take(func, [:label, :short, :name]))
          end)
          |> update_in([fname, :signatures], fn sigs ->
            (sigs || []) ++ [{sig_args, sig_ret}]
          end)
        else
          candidates
        end
      end)
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

  defp args_partial_match?(sig_args, req_args) do
    req_args
    |> Enum.with_index()
    |> Enum.all?(fn {t, idx} ->
      s = Enum.at(sig_args, idx)
      t == :any || s == :any || t == s
    end)
  end
end
