defmodule VacEngineWeb.EditorLive.VariableListComponent do
  use Phoenix.Component

  import Elixir.Integer
  import VacEngine.VariableHelpers
  import VacEngineWeb.IconComponent

  alias VacEngineWeb.EditorLive.VariableComponent, as: Variable

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
          <%= for {variable, index}
                  <- @renderable.input_variables |> Enum.with_index() do %>
            <Variable.render
              variable={variable}
              even={is_even(index)}
              mapping="input"
              selection_path={@selection_path}
            />
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
        <%= for {variable, index}
                <- @renderable.intermediate_variables |> Enum.with_index() do %>
          <Variable.render
            variable={variable}
            even={is_even(index)}
            mapping="intermediate"
            selection_path={@selection_path}
          />
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
        <%= for {variable, index}
                <- @renderable.output_variables |> Enum.with_index() do %>
          <Variable.render
            variable={variable}
            even={is_even(index)}
            mapping="output"
            selection_path={@selection_path}
          />
        <% end %>
      </tbody>
    </table>
    """
  end

  def build_renderable(variables) do
    input = variables |> flatten_variables("input")
    output = variables |> flatten_variables("output")
    intermediate = variables |> flatten_variables("intermediate")

    %{
      input_variables: input,
      output_variables: output,
      intermediate_variables: intermediate
    }
  end
end
