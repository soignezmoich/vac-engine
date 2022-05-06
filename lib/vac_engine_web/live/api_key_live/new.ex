defmodule VacEngineWeb.ApiKeyLive.New do
  @moduledoc """
  Form for API-key creation.
  """

  use VacEngineWeb, :live_view

  import VacEngine.PipeHelpers

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

    socket
    |> assign(changeset: changeset)
    |> ok()
  end

  @impl true
  def handle_params(_params, _session, socket) do
    {:noreply, socket}
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

    socket
    |> assign(changeset: changeset)
    |> noreply()
  end

  @impl true
  def handle_event(
        "create",
        %{"role" => params},
        socket
      ) do
    can!(socket, :manage, :api_keys)

    with {:ok, role} <- Account.create_role(:api, params),
         {:ok, _token} <- Account.create_api_token(role, role.test) do
      socket
      |> push_redirect(to: Routes.api_key_path(socket, :edit, role))
      |> noreply()
    else
      {:error, changeset} ->
        socket
        |> assign(changeset: changeset)
        |> noreply()
    end
  end
end
