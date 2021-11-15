defmodule VacEngineWeb.ApiKeyLive.Edit do
  use VacEngineWeb, :live_view

  alias VacEngine.Account

  on_mount(VacEngineWeb.LiveRole)
  on_mount({VacEngineWeb.LiveLocation, ~w(admin api_key new)a})

  @impl true
  def mount(
        %{"role_id" => role_id},
        _session,
        socket
      ) do
    can!(socket, :manage, :api_keys)

    role = Account.get_role!(role_id, &Account.load_api_tokens/1)

    changeset =
      role
      |> Account.change_role()
      |> Map.put(:action, :update)

    {:ok,
     assign(socket,
       edited_role: role,
       changeset: changeset,
       secret_visible: false,
       token: List.first(role.api_tokens)
     )}
  end

  @impl true
  def handle_params(_params, _session, socket) do
    {:noreply, socket}
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
  def handle_event("reveal_secret", _, socket) do
    Process.send_after(self(), :hide_secret, 10_000)

    {:noreply,
     socket
     |> assign(secret_visible: true)}
  end

  @impl true
  def handle_event(
        "delete",
        _,
        %{assigns: %{edited_role: role}} = socket
      ) do
    can!(socket, :delete, role)
    {:ok, _} = Account.delete_role(role)

    {:noreply,
     socket
     |> push_redirect(to: Routes.api_key_path(socket, :index), replace: true)}
  end

  @impl true
  def handle_info(:hide_secret, socket) do
    {:noreply, assign(socket, secret_visible: false)}
  end
end
