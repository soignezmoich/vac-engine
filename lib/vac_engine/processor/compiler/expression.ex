defmodule VacEngine.Processor.Compiler.Expression do
  defstruct ast: nil

  alias VacEngine.Processor.Compiler.Libraries

  def new(data) do
    ast = sanitize(data)

    {:ok, %__MODULE__{ast: ast}}
  rescue
    err ->
      case err do
        %{message: msg} ->
          {:error, msg}

        err ->
          {:error, inspect(err)}
      end
  end

  def sanitize(i) when is_number(i), do: i
  def sanitize(var) when is_atom(var), do: sanitize(to_string(var))

  def sanitize(var) when is_binary(var) do
    Regex.replace(~r/[^a-z_]/, var, "_")
  end

  def sanitize({f, _, args}), do: sanitize({f, args})
  def sanitize([f, _, args]), do: sanitize({f, args})

  def sanitize([f, args]) when is_list(args) do
    sanitize({f, args})
  end

  def sanitize({f, args}) when is_list(args) and is_binary(f) do
    fname = String.to_existing_atom(f)
    sanitize({fname, args})
  rescue
    _ ->
      raise "undefined function #{f}/#{length(args)}"
  end

  def sanitize({:@, args}), do: sanitize({:var, args})
  def sanitize({f, args}) when is_atom(f) and is_list(args) do
    ari = length(args)
    unless function_exported?(Libraries, f, ari) do
      raise "undefined function #{f}/#{ari}"
    end

    {f, Enum.map(args, &sanitize/1)}
  end

  def sanitize({f, args}) when not is_list(args) do
    to_string(f)
  end

  def sanitize(_expr) do
    raise "invalid expression"
  end
end

