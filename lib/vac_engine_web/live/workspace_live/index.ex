defmodule VacEngineWeb.WorkspaceLive.Index do
  use VacEngineWeb, :live_view
  use VacEngineWeb.TooltipHelpers

  alias VacEngine.Account

  on_mount(VacEngineWeb.LiveRole)
  on_mount({VacEngineWeb.LiveLocation, ~w(admin workspace)a})

  @impl true
  def mount(_params, _session, socket) do
    can!(socket, :manage, :workspaces)

    {:ok,
     assign(socket,
       workspaces: Account.list_workspaces(),
       current_tooltip: nil,
       clear_tooltip_ref: nil
     )}
  end

  @impl true
  def handle_event(
        "delete",
        %{"key" => "delete." <> wid = key},
        %{assigns: %{current_tooltip: key}} = socket
      ) do
    can!(socket, :manage, :workspaces)

    wid
    |> Account.get_workspace!()
    |> Account.delete_workspace()
    |> case do
      {:ok, _w} ->
        {:noreply,
         socket
         |> assign(workspaces: Account.list_workspaces())
         |> clear_flash
         |> clear_tooltip}

      {:error, err} ->
        {:noreply,
         socket
         |> put_flash(:error, "Cannot delete workspace: #{err}.")
         |> clear_tooltip}
    end
  end

  @impl true
  def handle_event(
        "delete",
        %{"key" => key},
        socket
      ) do
    {:noreply, set_tooltip(socket, key)}
  end
end
