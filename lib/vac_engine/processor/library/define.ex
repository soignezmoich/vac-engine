defmodule VacEngine.Processor.Library.Define do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :signature, accumulate: true)

      Module.register_attribute(__MODULE__, :functions,
        accumulate: false,
        persist: true
      )

      @on_definition {VacEngine.Processor.Library.Define, :define_func}
    end
  end

  @doc false
  def define_func(env, :def, name, args, _guards, _body) do
    arity = length(args)
    signatures = Module.get_attribute(env.module, :signature)
    label = Module.get_attribute(env.module, :label)
    short = Module.get_attribute(env.module, :short)
    rename = Module.get_attribute(env.module, :rename)

    Module.delete_attribute(env.module, :signature)
    Module.delete_attribute(env.module, :label)
    Module.delete_attribute(env.module, :short)
    Module.delete_attribute(env.module, :rename)

    name =
      if rename do
        rename
      else
        name
      end

    func = %{
      signatures: signatures,
      name: name,
      arity: arity,
      label: label,
      short: short
    }

    funcs = Module.get_attribute(env.module, :functions) || %{}

    funcs =
      if length(signatures) > 0 do
        funcs
        |> update_in([name], &(&1 || %{}))
        |> put_in([name, arity], func)
      else
        funcs
      end

    Module.put_attribute(env.module, :functions, funcs)
  end

  def define_func(_env, _kind, _name, _args, _guards, _body), do: nil
end
