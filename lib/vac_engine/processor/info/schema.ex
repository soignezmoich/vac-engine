defmodule VacEngine.Processor.Info.Schema do
  alias VacEngine.Processor.Variable
  alias VacEngine.Processor.Meta

  def input_schema(blueprint) do
    filter = fn var ->
      Variable.input?(var)
    end

    blueprint.variables
    |> map_children(filter)
    |> wrap_props()
  end

  def output_schema(blueprint) do
    filter = fn var ->
      Variable.output?(var)
    end

    blueprint.variables
    |> map_children(filter)
    |> wrap_props()
  end

  defp wrap_props(props) do
    %{
      "$schema" => "https://json-schema.org/draft/2019-09/schema"
    }
    |> Map.merge(props)
  end

  defp map_vars(vars, filter) do
    vars
    |> Enum.filter(filter)
    |> Enum.reduce(%{}, fn v, props ->
      Map.merge(props, map_var(v, filter))
    end)
  end

  defp map_var(%Variable{type: :map, name: name} = v, filter) do
    %{
      name => map_children(v.children, filter)
    }
  end

  defp map_var(%Variable{type: :"map[]", name: name} = v, filter) do
    %{
      name =>
        %{
          type: "array",
          items: map_children(v.children, filter)
        }
        |> append_if_not_empty(description: v.description)
    }
  end

  defp map_var(%Variable{type: :date, name: name} = v, _filter) do
    %{
      name =>
        %{
          type: "string",
          format: "date"
        }
        |> append_if_not_empty(description: v.description)
    }
  end

  defp map_var(%Variable{type: :datetime, name: name} = v, _filter) do
    %{
      name =>
        %{
          type: "string",
          format: "date-time"
        }
        |> append_if_not_empty(description: v.description)
    }
  end

  defp map_var(%Variable{} = v, _filter) do
    cond do
      Variable.list?(v) -> map_list(v)
      true -> map_flat(v)
    end
  end

  defp map_flat(%Variable{type: type, name: name} = v) do
    %{
      name =>
        %{
          type: type
        }
        |> append_if_not_empty(enum: v.enum, description: v.description)
    }
  end

  defp map_list(%Variable{type: type, name: name} = v) do
    %{
      name =>
        %{
          type: :array,
          items: %{
            type: Meta.itemize_type(type)
          }
        }
        |> append_if_not_empty(description: v.description)
    }
  end

  defp map_children(children, filter) do
    props =
      children
      |> Enum.filter(filter)
      |> map_vars(filter)

    required =
      children
      |> Enum.filter(filter)
      |> Enum.filter(&Variable.required?/1)
      |> Enum.map(& &1.name)

    %{
      type: "object",
      properties: props
    }
    |> append_if_not_empty(required: required)
  end

  def append_if_not_empty(map, to_add) do
    to_add
    |> Enum.reject(fn
      {_, []} -> true
      {_, nil} -> true
      {_, _} -> false
    end)
    |> Map.new()
    |> Map.merge(map)
  end
end
