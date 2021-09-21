defmodule VacEngine.PermissionsType do
  use Ecto.Type

  defstruct read: false, write: false, delete: false, delegate: false

  def type, do: :permissions

  def cast(nil) do
    perm = %__MODULE__{
      read: false,
      write: false,
      delete: false,
      delegate: false
    }

    {:ok, perm}
  end

  def cast(map) when is_map(map) do
    perm = %__MODULE__{
      read: extract(map, :read),
      write: extract(map, :write),
      delete: extract(map, :delete),
      delegate: extract(map, :delegate)
    }

    {:ok, perm}
  end

  def cast(_), do: :error

  def load({read, write, delete, delegate}) do
    {:ok,
     %__MODULE__{
       read: read,
       write: write,
       delete: delete,
       delegate: delegate
     }}
  end

  def load(_data), do: :error

  def dump(%__MODULE__{} = perm) do
    {:ok, {perm.read, perm.write, perm.delete, perm.delegate}}
  end

  def dump(_), do: :error

  defp extract(map, key) do
    Map.get_lazy(map, Atom.to_string(key), fn -> Map.get(map, key, false) end)
  end
end
