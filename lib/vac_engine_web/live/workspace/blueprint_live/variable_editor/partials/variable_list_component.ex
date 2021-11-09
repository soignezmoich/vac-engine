defmodule VacEngineWeb.Editor.VariableListComponent do
  use Phoenix.Component

  import Elixir.Integer
  import VacEngineWeb.IconComponent

  alias VacEngine.Processor.Variable, as: PVariable
  alias VacEngineWeb.Editor.VariableComponent, as: Variable

  def render(assigns) do
    assigns =
      assign(assigns,
        renderable: build_renderable(assigns.variables)
      )

    ~H"""
    <table class="w-full">
        <thead>
          <tr>
            <th colspan="3" class="bg-cream-500 text-white py-1 px-4">
              <div class="-mt-1 inline-block align-middle">
                <.icon name="input" width="1.25rem" />
              </div>
              Input Variables
            </th>
          </tr>
          <tr>
            <th class="bg-cream-400 text-white py-1 px-2 text-left">Name</th>
            <th class="bg-cream-400 text-white py-1 px-2 text-left">Type</th>
            <th class="bg-cream-400 text-white py-1 px-2 text-left">Common Values</th>
          </tr>
        </thead>
        <tbody>
          <%= for {%{path: path, variable: variable}, index}
                  <- @renderable.input_variables |> Enum.with_index() do %>
            <Variable.render
              variable={variable}
              path={path}
            even={is_even(index)}
            mapping="input" />
        <% end %>
        <tr><td><br/><br/></td></tr>
      </tbody>
      <thead>
        <tr>
          <th colspan="3" class="bg-blue-500 text-white py-1 px-4">
            <div class="-mt-1 inline-block align-middle">
              <.icon name="hero/variable" width="1.25rem" />
            </div>
            Intermediate Variables
          </th>
        </tr>
        <tr>
        <th class="bg-blue-400 text-white py-1 px-2 text-left">Name</th>
        <th class="bg-blue-400 text-white py-1 px-2 text-left">Type</th>
        <th class="bg-blue-400 text-white py-1 px-2 text-left">Common Values</th>
      </tr>
      </thead>
      <tbody>
        <%= for {%{path: path, variable: variable}, index}
                <- @renderable.intermediate_variables |> Enum.with_index() do %>
          <Variable.render
            variable={variable}
            path={path}
            even={is_even(index)}
            mapping="intermediate" />
        <% end %>
        <tr><td><br/><br/></td></tr>
      </tbody>
      <thead>
        <tr>
          <th colspan="3" class="whitespace-nowrap bg-blue-500 text-white py-1 px-4">
            <div class="-mt-1 inline-block align-middle">
              <.icon name="hero/logout" width="1.25rem" />
            </div>
            Output Variables
          </th>
        </tr>
        <tr>
        <th class="bg-blue-400 text-white py-1 px-2 text-left">Name</th>
        <th class="bg-blue-400 text-white py-1 px-2 text-left">Type</th>
        <th class="bg-blue-400 text-white py-1 px-2 text-left">Common Values</th>
      </tr>
      </thead>
      <tbody>
        <%= for {%{path: path, variable: variable}, index}
                <- @renderable.output_variables |> Enum.with_index() do %>
          <Variable.render
            variable={variable}
            path={path}
            even={is_even(index)}
            mapping="output" />
        <% end %>
      </tbody>
    </table>
    """
  end

  def build_renderable(variables) do
    input =
      variables
      |> Enum.filter(fn variable -> PVariable.input?(variable) end)
      |> Enum.flat_map(fn variable ->
        flatten_tree(["input", "variables"], variable)
      end)
      |> Enum.map(fn {path, variable} ->
        %{path: path |> Enum.reverse(), variable: variable}
      end)

    output =
      variables
      |> Enum.filter(fn variable -> PVariable.output?(variable) end)
      |> Enum.flat_map(fn variable ->
        flatten_tree(["output", "variables"], variable)
      end)
      |> Enum.map(fn {path, variable} ->
        %{path: path |> Enum.reverse(), variable: variable}
      end)

    intermediate =
      variables
      |> Enum.filter(fn variable ->
        !PVariable.input?(variable) && !PVariable.output?(variable)
      end)
      |> Enum.flat_map(fn variable ->
        flatten_tree(["intermediate", "variables"], variable)
      end)
      |> Enum.map(fn {path, variable} ->
        %{path: path |> Enum.reverse(), variable: variable}
      end)

    %{
      input_variables: input,
      output_variables: output,
      intermediate_variables: intermediate
    }
  end

  # Flatten the variable tree as a (reversed) list and add path each variable.
  defp flatten_tree(parent_path, variable) do
    current_path = [variable.name | parent_path]

    case variable do
      %{children: children} ->
        [
          {current_path, variable}
          | children
            |> Enum.flat_map(fn child -> flatten_tree(current_path, child) end)
        ]

      _ ->
        [{current_path, variable}]
    end
  end
end
