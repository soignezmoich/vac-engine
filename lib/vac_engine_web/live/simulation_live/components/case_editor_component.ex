defmodule VacEngineWeb.SimulationLive.CaseEditorComponent do
  use Phoenix.Component

  alias VacEngineWeb.SimulationLive.CaseInputEditorComponent, as: InputEditor
  alias VacEngineWeb.SimulationLive.CaseOutputEditorComponent, as: OutputEditor

  def render(assigns) do
    ~H"""
    <div class="m-3">
      <div class="text-2xl font-bold mb-4">Case: <%= @case.name %></div>
      <div class="font-bold">Template</div>
      <input class="form-fld" value={@case.template} />
      <div class="h-4"/>
      <div class="grid sm:grid-cols-1 2xl:grid-cols-2 gap-3">
        <.live_component
          id="case_input"
          module={InputEditor}
          blueprint={@blueprint}
          case={@case}
          template={extract_template(@case, @templates)}
        />
        <.live_component
          id="case_output"
          module={OutputEditor}
          blueprint={@blueprint}
          case={@case} />
      </div>
    </div>
    """
  end

  def extract_template(kase, templates) do
    templates |> Enum.find(&(&1.name == kase.template))
  end

end
