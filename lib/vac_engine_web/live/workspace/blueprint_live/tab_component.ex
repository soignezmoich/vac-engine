defmodule VacEngineWeb.Workspace.BlueprintLive.TabComponent do
  use VacEngineWeb, :component
  alias VacEngineWeb.Endpoint

  def tab_bar(assigns) do
    ~H"""
    <div class="flex justify-end bg-cream-200 shadow-md">
      <.tab label="Editor" blueprint={@blueprint} target={:editor} current={@current} />
      <.tab label="Deductions" blueprint={@blueprint} target={:deductions} current={@current} />
    </div>
    """
  end

  def tab(
        %{
          target: target,
          current: current,
          blueprint: %{id: id, workspace_id: workspace_id}
        } = assigns
      ) do
    args = [Endpoint, target, workspace_id, id]

    class =
      if current == target do
        "font-bold bg-cream-300 px-4 py-1 "
      else
        "font-normal px-4 py-1 "
      end

    assigns =
      assign(assigns,
        url: apply(Routes, :workspace_blueprint_path, args),
        class: class
      )

    ~H"""
    <%= live_patch(@label, to: @url, class: @class) %>
    """
  end
end
