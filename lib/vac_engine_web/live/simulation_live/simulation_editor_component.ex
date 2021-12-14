defmodule VacEngineWeb.SimulationLive.SimulationEditorComponent do
  use VacEngineWeb, :live_component

  alias VacEngineWeb.SimulationLive.CaseEditorComponent
  alias VacEngineWeb.SimulationLive.ConfigEditorComponent
  alias VacEngineWeb.SimulationLive.MenuCaseListComponent
  alias VacEngineWeb.SimulationLive.MenuConfigComponent
  alias VacEngineWeb.SimulationLive.MenuTemplateListComponent
  alias VacEngineWeb.SimulationLive.TemplateEditorComponent

  def update(assigns, socket) do

    simulation = %{
      config: %{
        now: "2021-11-15"
      },
      templates: [
        %{
          name: "booster",
          type: "template",
          input: %{
            birthdate: "1991-01-01",
            high_risk: true,
            infection_date: nil,
            rejects_mrna: false,
            previous_vaccination: %{
              vaccine: "moderna",
              last_dose_date: "2021-02-02",
              doses_count: 2,
            },
          },
        },
      ],
      cases: [
        %{
          name: "flag-under-12",
          type: "case",
          template: "booster",
          input: %{
            birthdate: "2009-12-16",
          },
          expect: %{
            flags: %{
              under_12: true,
            },
          },
          forbid: %{
            injection_sequence: true,
          },
          actual: %{
            flags: %{
              under_12: true,
            },
            delay_cause: "infection",
            injection_sequence: %{
              janssen: %{
                vaccine: "janssen",
                delay_max: 10,
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
              doses_count: 3,
            },
          },
          expect: %{
            flags: %{
              no_booster_after_more_than_2_doses: true,
            },
          },
          forbid: %{
            injection_sequence: true,
          },
          actual: %{
            flags: %{
              no_booster_after_more_than_2_doses: true,
            }
          }
        }
      ]
    }


    {
      :ok,
      assign(socket,
        blueprint: assigns.blueprint,
        selected_element: simulation.cases |> Enum.at(0),
        simulation: simulation,
      )
    }
  end


  @impl true
  def handle_event("menu_select", params, socket) do

    selected_element =
      case params do
        %{"section" => "config"} ->
          :config
        %{"section" => "templates", "index" => index} ->
          {idx, _} = Integer.parse(index)
          socket.assigns.simulation.templates |> Enum.at(idx)
        %{"section" => "cases", "index" => index} ->
          {idx, _} = Integer.parse(index)
          socket.assigns.simulation.cases |> Enum.at(idx)
      end


    {:noreply,
     assign(socket, %{
       selected_element: selected_element,
     })}
  end

end
