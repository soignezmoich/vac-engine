defmodule VacEngineWeb.ApiKeyLive.New do
  use VacEngineWeb, :live_view

  alias VacEngine.Account
  alias VacEngine.Account.Role

  on_mount(VacEngineWeb.LiveRole)
  on_mount({VacEngineWeb.LiveLocation, ~w(admin api_key new)a})

  @impl true
  def mount(_params, _session, socket) do
    can!(socket, :manage, :api_keys)

    changeset =
      %Role{type: :api}
      |> Account.change_role()
      |> Map.put(:action, :insert)

    {:ok,
     assign(socket,
       changeset: changeset
     )}
  end

  @impl true
  def handle_event(
        "validate",
        %{"role" => params},
        socket
      ) do
    changeset =
      %Role{type: :api}
      |> Account.change_role(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event(
        "create",
        %{"role" => params},
        socket
      ) do
    can!(socket, :manage, :api_keys)

    with {:ok, role} <- Account.create_role(:api, params),
         {:ok, _token} <- Account.create_api_token(role) do
      {:noreply,
       socket
       |> push_redirect(to: Routes.api_key_path(socket, :edit, role))}
    else
      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
