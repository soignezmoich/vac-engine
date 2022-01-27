defmodule VacEngineWeb.SimulationLive.SimulationEditorComponent do
  use VacEngineWeb, :live_component

  alias VacEngine.Simulation
  alias VacEngine.Simulation.Case
  alias VacEngine.Simulation.Stack

  alias VacEngineWeb.SimulationLive.CaseEditorComponent
  alias VacEngineWeb.SimulationLive.ConfigEditorComponent
  alias VacEngineWeb.SimulationLive.MenuCaseListComponent
  alias VacEngineWeb.SimulationLive.MenuConfigComponent
  alias VacEngineWeb.SimulationLive.MenuTemplateListComponent
  alias VacEngineWeb.SimulationLive.TemplateEditorComponent

  @impl true
  def update(assigns, socket) do
    templates =
      Map.get(assigns, :templates) ||
        Simulation.get_templates(assigns.blueprint)

    IO.puts("UPDATING SIMULATION EDITOR")

    stacks =
      Map.get(assigns, :stacks) || Simulation.get_stacks(assigns.blueprint)

    simulation = %{
      config: %{
        now: "2021-11-15"
      },
      # templates: [
      #   %{
      #     name: "booster",
      #     type: "template",
      #     input: %{
      #       birthdate: "1991-01-01",
      #       high_risk: true,
      #       infection_date: nil,
      #       rejects_mrna: false,
      #       previous_vaccination: %{
      #         vaccine: "moderna",
      #         last_dose_date: "2021-02-02",
      #         doses_count: 2
      #       }
      #     }
      #   }
      # ],
      #   cases: [
      #     %{
      #       name: "flag-under-12",
      #       type: "case",
      #       template: "test_template",
      #       input: %{
      #         birthdate: "2009-12-16"
      #       },
      #       expect: %{
      #         flags: %{
      #           under_12: true
      #         }
      #       },
      #       forbid: %{
      #         injection_sequence: true
      #       },
      #       actual: %{
      #         flags: %{
      #           under_12: true
      #         },
      #         delay_cause: "infection",
      #         injection_sequence: %{
      #           janssen: %{
      #             vaccine: "janssen",
      #             delay_max: 10
      #           }
      #         }
      #       }
      #     },
      #     %{
      #       name: "flag-no-booster-after-more-than-2-doses",
      #       type: "case",
      #       template: "test_template",
      #       input: %{
      #         previous_vaccination: %{
      #           doses_count: 3
      #         }
      #       },
      #       expect: %{
      #         flags: %{
      #           no_booster_after_more_than_2_doses: true
      #         }
      #       },
      #       forbid: %{
      #         injection_sequence: true
      #       },
      #       actual: %{
      #         flags: %{
      #           no_booster_after_more_than_2_doses: true
      #         }
      #       }
      #     }
      #   ]
      cases: []
    }

    selected_element =
      get_updated_selected_element(
        Map.get(assigns, :selected_element),
        templates,
        stacks
      )

    action = assigns |> Map.get(:action) || nil;

    socket =  assign(socket,
      blueprint: assigns.blueprint,
      templates: templates,
      stacks: stacks,
      selected_element: selected_element,
      simulation: simulation,
      action: action,
    )

    hash = :crypto.hash(:md5, :erlang.term_to_binary(socket)) |> Base.encode64

    IO.inspect(hash)

    {
      :ok, socket
    }
  end

  @impl true
  def render(assigns) do

    IO.puts("RENDERING SIMULATION EDITOR")
    IO.puts("ACTION")
    IO.inspect(assigns.action)

     ~H"""
     <div class="relative flex-grow" id="simulation_editor">
      <div class="absolute inset-0 flex min-h-0">
        <div class="w-96 flex-shrink-0 mr-2 flex flex-col overflow-y-auto mt-3">
          <div class="mx-2">
            <MenuConfigComponent.render
              selected_element={@selected_element}
            />
            <div class="h-4" />
            <MenuTemplateListComponent.render
              templates={@templates}
              selected_element={@selected_element}
            />
            <div class="h-4" />
            <MenuCaseListComponent.render
              cases={@simulation.cases}
              stacks={@stacks}
              selected_element={@selected_element}
            />
          </div>
        </div>
        <div class="flex-grow flex flex-col overflow-y-auto">
          <div class="flex-shrink">
            <%= case @selected_element do %>
            <% :config -> %>
              <ConfigEditorComponent.render
                configuration={@simulation.config}
              />
            <% %{runnable: false} -> %>
              <TemplateEditorComponent.render
                template={@selected_element}
                blueprint={@blueprint}
              />
            <% %Stack{} -> %>
              <.live_component
              module={CaseEditorComponent}
              id="case-editor-component"
              stack={@selected_element}
              blueprint={@blueprint}
              templates={@templates}
              action={@action} />
            <% other -> %>
              <div class={"ml-5 mt-10"}>
                <p>No element selected.</p>
                <div><%= inspect(other)%></div>
              </div>
            <% end %>
          </div>
          <div><%= inspect(@action) %></div>
        </div>
      </div>
    </div>
    """
  end

  def get_updated_selected_element(old_selected_element, templates, stacks) do
    case old_selected_element do
      # template
      %Case{id: id, runnable: false} ->
        IO.puts("TEMPLATE")
        templates |> Enum.find(&(&1.id == id))

      # case
      %Stack{id: id} ->
        IO.puts("STACK")
        stacks |> Enum.find(&(&1.id == id))

      # none
      _ ->
        IO.puts("NONE")
        stacks |> List.first()
    end
  end

  @impl true
  def handle_event("menu_select", params, socket) do
    IO.puts("MENU SELECT EVENT index=#{params["index"]}")
    selected_element =
      case params do
        %{"section" => "config"} ->
          :config

        %{"section" => "templates", "index" => index} ->
          {idx, _} = Integer.parse(index)
          socket.assigns.templates |> Enum.at(idx)

        %{"section" => "cases", "index" => index} ->
          {idx, _} = Integer.parse(index)
          socket.assigns.stacks |> Enum.at(idx)
      end

    # send_update(SimulationEditorComponent,
    #   id: "simulation_editor",
    #   selected_element: selected_element,
    #   blueprint: socket.assigns.blueprint,
    #   stacks: socket.assigns.stacks,
    #   templates: socket.assigns.templates,
    #   action: "refresh-#{:rand.uniform()}"
    # )

    {:noreply,
     assign(socket, %{
       selected_element: selected_element,
       action: %{type: :refresh, token: :rand.uniform()}
       })}
  end

  def handle_event("create_template", %{"new_template_name" => name}, socket) do
    new_template_case_id =
      case Simulation.create_template(socket.assigns.blueprint, name) do
        {:ok, %{case: %Case{id: id}}} -> id
      end

    templates = Simulation.get_templates(socket.assigns.blueprint)

    selected_element = templates |> Enum.find(&(&1.id == new_template_case_id))

    {:noreply,
     assign(socket, %{
       templates: templates,
       selected_element: selected_element
     })}
  end

  def handle_event("create_stack", %{"new_case_name" => name}, socket) do
    new_stack_id =
      case Simulation.create_stack(socket.assigns.blueprint, name) do
        {:ok, %{case: %Case{id: id}}} -> id
      end

    stacks = Simulation.get_stacks(socket.assigns.blueprint)

    selected_element = stacks |> Enum.find(&(&1.id == new_stack_id))

    {:noreply,
     assign(socket, %{
       stacks: stacks,
       selected_element: selected_element
     })}
  end
end
