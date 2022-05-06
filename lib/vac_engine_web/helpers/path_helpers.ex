defmodule VacEngineWeb.PathHelpers do
  @moduledoc false

  @doc """
    Extract the common prefix of the given lists.

    # Params
      - the list of lists on which the prefix should be extracted.
        (currently only works on lists of equalizable items)

    # Returns
      - the common prefix
      - the lists truncated of the common prefix
  """
  @spec extract_prefix([list()]) :: {list(), [list()]}
  def extract_prefix([]) do
    {[], []}
  end

  def extract_prefix([_ | _] = list_of_lists) do
    extract_prefix([], shortest(list_of_lists), list_of_lists)
  end

  defp shortest([_ | _] = list_of_lists) do
    list_of_lists
    |> Enum.sort_by(&length(&1))
    |> List.first()
  end

  defp extract_prefix(prefix, [], list) do
    {prefix, list}
  end

  defp extract_prefix(prefix, [_singe_element], list) do
    {prefix, list}
  end

  defp extract_prefix(prefix, [elem | rest], list) do
    same_first = Enum.all?(list, &(&1 |> List.first() == elem))

    if same_first && elem do
      extract_prefix(
        prefix ++ [elem],
        rest,
        list |> Enum.map(&(&1 |> Enum.drop(1)))
      )
    else
      {prefix, list}
    end
  end
end
