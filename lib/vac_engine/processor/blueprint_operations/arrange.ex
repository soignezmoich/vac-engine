defmodule VacEngine.Processor.Blueprints.Arrange do
  @moduledoc false

  import VacEngine.Processor.Blueprints.VariableIndex

  alias VacEngine.Processor.Assignment
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Condition
  alias VacEngine.Processor.Column
  alias VacEngine.Processor.Variable

  def arrange_all(nil), do: nil

  def arrange_all(blueprint) do
    blueprint
    |> arrange_variables()
    |> arrange_columns()
    |> arrange_assignments()
    |> arrange_conditions()
  end

  defp arrange_variables(
         %Blueprint{variables: %Ecto.Association.NotLoaded{}} = br
       ) do
    br
  end

  defp arrange_variables(blueprint) do
    {var_tree, id_index, path_index} =
      blueprint.variables
      |> index_variables()
      |> insert_variable_default_bindings()

    {input_variables, output_variables, intermediate_variables} =
      blueprint.variables
      |> Enum.map(fn var -> Map.get(id_index, var.id) end)
      |> Enum.sort_by(fn var -> var.path end)
      |> Enum.reduce({[], [], []}, fn var, {inp, out, rest} ->
        inp =
          if Variable.input?(var) do
            [var | inp]
          else
            inp
          end

        out =
          if Variable.output?(var) do
            [var | out]
          else
            out
          end

        rest =
          if !Variable.input?(var) and !Variable.output?(var) do
            [var | rest]
          else
            rest
          end

        {inp, out, rest}
      end)
      |> Tuple.to_list()
      |> Enum.map(&Enum.reverse/1)
      |> List.to_tuple()

    %{
      blueprint
      | variables: var_tree,
        variable_path_index: path_index,
        variable_id_index: id_index,
        input_variables: input_variables,
        output_variables: output_variables,
        intermediate_variables: intermediate_variables
    }
  end

  defp insert_variable_default_bindings({var_tree, path_index}) do
    id_index =
      path_index
      |> Enum.map(fn {_path, var} ->
        {var.id, var}
      end)
      |> Map.new()

    insert_variable_default_bindings(var_tree, id_index, %{}, %{})
  end

  defp insert_variable_default_bindings(
         var_tree,
         id_index,
         new_id_index,
         new_path_index
       ) do
    var_tree
    |> Enum.reduce(
      {[], new_id_index, new_path_index},
      fn var, {new_tree, new_id_index, new_path_index} ->
        {children_tree, new_id_index, new_path_index} =
          insert_variable_default_bindings(
            var.children,
            id_index,
            new_id_index,
            new_path_index
          )

        var = Variable.insert_bindings(var, %{variable_id_index: id_index})
        var = %{var | children: children_tree}
        new_path_index = Map.put(new_path_index, var.path, var)
        new_id_index = Map.put(new_id_index, var.id, var)
        new_tree = new_tree ++ [var]

        {new_tree, new_id_index, new_path_index}
      end
    )
  end

  defp arrange_columns(
         %Blueprint{deductions: %Ecto.Association.NotLoaded{}} = br
       ) do
    br
  end

  defp arrange_columns(blueprint) do
    blueprint
    |> update_in(
      [
        Access.key(:deductions),
        Access.all(),
        Access.key(:columns),
        Access.all()
      ],
      fn col ->
        Column.insert_bindings(col, blueprint)
      end
    )
  end

  defp arrange_assignments(
         %Blueprint{deductions: %Ecto.Association.NotLoaded{}} = br
       ) do
    br
  end

  defp arrange_assignments(blueprint) do
    blueprint
    |> update_in(
      [
        Access.key(:deductions),
        Access.all(),
        Access.key(:branches),
        Access.all(),
        Access.key(:assignments),
        Access.all()
      ],
      fn assign ->
        Assignment.insert_bindings(assign, blueprint)
      end
    )
    |> update_in(
      [
        Access.key(:deductions),
        Access.all(),
        Access.key(:branches),
        Access.all(),
        Access.key(:assignments)
      ],
      fn assigns ->
        Enum.sort_by(assigns, fn a ->
          {a.id, a.column && a.column.position}
        end)
      end
    )
  end

  defp arrange_conditions(
         %Blueprint{deductions: %Ecto.Association.NotLoaded{}} = br
       ) do
    br
  end

  defp arrange_conditions(blueprint) do
    blueprint
    |> update_in(
      [
        Access.key(:deductions),
        Access.all(),
        Access.key(:branches),
        Access.all(),
        Access.key(:conditions),
        Access.all()
      ],
      fn con ->
        Condition.insert_bindings(con, blueprint)
      end
    )
    |> update_in(
      [
        Access.key(:deductions),
        Access.all(),
        Access.key(:branches),
        Access.all(),
        Access.key(:conditions)
      ],
      fn conds ->
        Enum.sort_by(conds, fn a ->
          {a.id, a.column && a.column.position}
        end)
      end
    )
  end
end
