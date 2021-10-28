defmodule VacEngineWeb.Editor.CellRenderable do

  @doc """
  Create a cell renderable data from
  a blueprint condition or assignment object (and extra data).
  """
  def build(source, type, path, selected_path, even_row?) do

    text = case source do
      %{expression: %{ast: ast}} -> ast_text(ast, type)
      nil -> "-"
    end

    description = case source do
      %{description: description} -> description
      _ -> nil
    end


    %{
      description: description,
      even_row?: even_row?,
      path: path,
      selected?: path == selected_path,
      text: text
    }

  end


  defp ast_text({:var, _signature, [path]}, _type) do

    # text for vaiable ast

    dot_path = path
      |> Enum.join(".")

    "@#{dot_path}"
  end


  defp ast_text({op, _signature, args}, type) do

    # text for operator (+args) ast

    amount_to_drop = if type == :condition do 1 else 0 end

    op_text = Atom.to_string(op)
    args_text =
      args
      |> Enum.drop(amount_to_drop)
      |> Enum.map(&(ast_text(&1, type)))
      |> Enum.join(" ")

    "#{op_text} #{args_text}"
  end


  defp ast_text(string_const, _type) when is_binary(string_const) do

    # text for string ast

    string_const
  end


  defp ast_text(const, _type) do

    # text for other const

    inspect(const)
  end

end
