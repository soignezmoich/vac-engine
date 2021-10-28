defmodule VacEngineWeb.Editor.ColumnHeaderRenderable do

  @doc """
  Create a column cell renderable data from
  a column and extra data.
  """
  def build(
    %{description: description, type: type},
    min_distinct_path,
    var_may_be_nil?,
    default_to_false?
  ) do

    text = case {description, min_distinct_path} do
      {string, _} when is_binary(string)
        -> string
      {_, path} when is_list(path)
        -> path |> Enum.join(".")
    end

    %{
      defaults_to_false?: default_to_false?,
      var_may_be_nil?: var_may_be_nil?,
      text: text,
      type: type
    }

  end

end
