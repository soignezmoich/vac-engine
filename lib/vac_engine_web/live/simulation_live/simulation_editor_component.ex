defmodule VacEngineWeb.SimulationLive.SimulationEditorComponent do
  use VacEngineWeb, :live_component

  alias VacEngine.Simulation
  alias VacEngine.Simulation.Case

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
      cases: [
        %{
          name: "flag-under-12",
          type: "case",
          template: "booster",
          input: %{
            birthdate: "2009-12-16"
          },
          expect: %{
            flags: %{
              under_12: true
            }
          },
          forbid: %{
            injection_sequence: true
          },
          actual: %{
            flags: %{
              under_12: true
            },
            delay_cause: "infection",
            injection_sequence: %{
              janssen: %{
                vaccine: "janssen",
                delay_max: 10
              }
            }
          }
        },
        %{
          name: "flag-no-booster-after-more-than-2-doses",
          type: "case",
          template: "booster",
          input: %{
            previous_vaccination: %{
              doses_count: 3
            }
          },
          expect: %{
            flags: %{
              no_booster_after_more_than_2_doses: true
            }
          },
          forbid: %{
            injection_sequence: true
          },
          actual: %{
            flags: %{
              no_booster_after_more_than_2_doses: true
            }
          }
        }
      ]
    }

    selected_element =
      get_updated_selected_element(
        Map.get(assigns, :selected_element),
        templates,
        []
      )

    {
      :ok,
      assign(socket,
        blueprint: assigns.blueprint,
        templates: templates,
        selected_element: selected_element,
        simulation: simulation
      )
    }
  end

  def get_updated_selected_element(old_selected_element, templates, _cases) do
    case old_selected_element do
      # template
      %Case{id: id, runnable: false} -> templates |> Enum.find(&(&1.id == id))
      # none
      _ -> templates |> List.first()
    end
  end

  @impl true
  def handle_event("menu_select", params, socket) do
    selected_element =
      case params do
        %{"section" => "config"} ->
          :config

        %{"section" => "templates", "index" => index} ->
          {idx, _} = Integer.parse(index)
          socket.assigns.templates |> Enum.at(idx)

        %{"section" => "cases", "index" => index} ->
          {idx, _} = Integer.parse(index)
          socket.assigns.simulation.cases |> Enum.at(idx)
      end

    {:noreply,
     assign(socket, %{
       selected_element: selected_element
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
end
