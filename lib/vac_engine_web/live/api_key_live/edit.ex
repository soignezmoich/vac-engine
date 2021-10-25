defmodule VacEngineWeb.ApiKeyLive.Edit do
  use VacEngineWeb, :live_view
  use VacEngineWeb.TooltipHelpers

  alias VacEngine.Account
  alias VacEngine.Account.Role

  on_mount(VacEngineWeb.LiveRole)
  on_mount({VacEngineWeb.LiveLocation, ~w(admin api_key new)a})

  @impl true
  def mount(
        %{"role_id" => role_id},
        _session,
        %{assigns: %{role: role}} = socket
      ) do
    can!(socket, :manage, :api_keys)

    role =
      Account.get_role!(role_id)
      |> Account.load_api_tokens()

    changeset =
      role
      |> Account.change_role()
      |> Map.put(:action, :update)

    {:ok,
     assign(socket,
       current_tooltip: nil,
       clear_tooltip_ref: nil,
       edited_role: role,
       changeset: changeset,
       secret_visible: false,
       secret: List.first(role.api_tokens).secret
     )}
  end

  @impl true
  def handle_event(
        "validate",
        %{"role" => params},
        %{assigns: %{edited_role: role}} = socket
      ) do
    changeset =
      role
      |> Account.change_role(params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event(
        "update",
        %{"role" => params},
        %{assigns: %{edited_role: role}} = socket
      ) do
    can!(socket, :manage, :api_keys)

    Account.update_role(role, params)
    |> case do
      {:ok, role} ->
        {:noreply,
         socket
         |> push_redirect(to: Routes.api_key_path(socket, :edit, role))}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_event(
        "reveal_secret",
        %{"key" => key},
        %{assigns: %{current_tooltip: key}} = socket
      ) do
    Process.send_after(self(), :hide_secret, 10000)

    {:noreply,
     socket
     |> clear_tooltip
     |> assign(secret_visible: true)}
  end

  @impl true
  def handle_event("reveal_secret", %{"key" => key}, socket) do
    {:noreply, set_tooltip(socket, key)}
  end

  @impl true
  def handle_event(
        "delete",
        %{"key" => key},
        %{assigns: %{current_tooltip: key, edited_role: role}} = socket
      ) do
    can!(socket, :delete, role)
    {:ok, _} = Account.delete_role(role)

    {:noreply,
     socket
     |> push_redirect(to: Routes.api_key_path(socket, :index))}
  end

  @impl true
  def handle_event("delete", %{"key" => key}, socket) do
    {:noreply, set_tooltip(socket, key)}
  end

  @impl true
  def handle_info(:hide_secret, socket) do
    {:noreply, assign(socket, secret_visible: false)}
  end
end
