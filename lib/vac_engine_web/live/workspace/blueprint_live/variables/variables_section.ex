defmodule VacEngineWeb.Editor.VariablesSection do
  use Phoenix.Component
  alias VacEngineWeb.Editor.Variable
  alias VacEngineWeb.Editor.VariableRenderables
  import Elixir.Integer
  import VacEngineWeb.Editor.FormActionsComponent
  import VacEngineWeb.Editor.VariableEditorComponent
  import VacEngineWeb.Editor.VariablesActionsComponent

  def variables_section(assigns) do

    renderable_variables = VariableRenderables.build(assigns.variables, nil)

    assigns =
      assign(assigns,
        input_variables: renderable_variables.input,
        output_variables: renderable_variables.output,
        intermediate_variables: renderable_variables.intermediate
      )

    ~H"""
      <div class="h-3" />
      <div class="flex min-h-0">
        <div class="w-64 mr-2 flex flex-col overflow-y-auto">
          <div class="flex-shrink ">
            <.form_actions />
            <div class="h-4" />
            <.variables_actions />
            <div class="h-4" />
            <.variable_editor />
          </div>
        </div>
        <div class="flex-grow flex flex-col overflow-y-auto">
          <div class="flex-shrink text-xs">
            <table class="w-full">
              <thead>
                <tr>
                  <th colspan="3" class="bg-cream-500 text-white py-1 px-4">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 inline-block" viewBox="0 0 20 20" fill="currentColor" transform="scale(-1,1)">
                      <path fill-rule="evenodd" d="M3 3a1 1 0 011 1v12a1 1 0 11-2 0V4a1 1 0 011-1zm7.707 3.293a1 1 0 010 1.414L9.414 9H17a1 1 0 110 2H9.414l1.293 1.293a1 1 0 01-1.414 1.414l-3-3a1 1 0 010-1.414l3-3a1 1 0 011.414 0z" clip-rule="evenodd" />
                    </svg>
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
                <%= for {variable, index} <- @input_variables |> Enum.with_index() do %>
                  <Variable.variable
                    variable={variable}
                    even={is_even(index)}
                    in_out="input" />
                <% end %>
                <tr><td><br/><br/></td></tr>
              </tbody>
              <thead>
                <tr>
                  <th colspan="3" class="bg-blue-500 text-white py-1 px-4">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 -mt-1 inline-block" viewBox="0 0 20 20" fill="currentColor">
                      <path fill-rule="evenodd" d="M4.649 3.084A1 1 0 015.163 4.4 13.95 13.95 0 004 10c0 1.993.416 3.886 1.164 5.6a1 1 0 01-1.832.8A15.95 15.95 0 012 10c0-2.274.475-4.44 1.332-6.4a1 1 0 011.317-.516zM12.96 7a3 3 0 00-2.342 1.126l-.328.41-.111-.279A2 2 0 008.323 7H8a1 1 0 000 2h.323l.532 1.33-1.035 1.295a1 1 0 01-.781.375H7a1 1 0 100 2h.039a3 3 0 002.342-1.126l.328-.41.111.279A2 2 0 0011.677 14H12a1 1 0 100-2h-.323l-.532-1.33 1.035-1.295A1 1 0 0112.961 9H13a1 1 0 100-2h-.039zm1.874-2.6a1 1 0 011.833-.8A15.95 15.95 0 0118 10c0 2.274-.475 4.44-1.332 6.4a1 1 0 11-1.832-.8A13.949 13.949 0 0016 10c0-1.993-.416-3.886-1.165-5.6z" clip-rule="evenodd" />
                    </svg>
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
                <%= for {variable, index} <- @intermediate_variables |> Enum.with_index() do %>
                  <Variable.variable
                    variable={variable}
                    even={is_even(index)}
                    in_out="output" />
                <% end %>
                <tr><td><br/><br/></td></tr>
              </tbody>
              <thead>
                <tr>
                  <th colspan="3" class="whitespace-nowrap bg-blue-500 text-white py-1 px-4">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 inline-block" viewBox="0 0 20 20" fill="currentColor">
                      <path fill-rule="evenodd" d="M3 3a1 1 0 00-1 1v12a1 1 0 102 0V4a1 1 0 00-1-1zm10.293 9.293a1 1 0 001.414 1.414l3-3a1 1 0 000-1.414l-3-3a1 1 0 10-1.414 1.414L14.586 9H7a1 1 0 100 2h7.586l-1.293 1.293z" clip-rule="evenodd" />
                    </svg>
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
                <%= for {variable, index} <- @output_variables |> Enum.with_index() do %>
                  <Variable.variable
                    variable={variable}
                    even={is_even(index)}
                    in_out="output" />
                <% end %>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    <br/>
    """
  end
end
