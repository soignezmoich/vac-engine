defmodule VacEngineWeb.AuthLive.Login do
  use VacEngineWeb, :live_view

  import VacEngineWeb.AuthLive.LoginFormComponent
  alias VacEngine.Account

  defmodule LoginForm do
    use Ecto.Schema
    import Ecto.Changeset

    embedded_schema do
      field(:email, :string)
      field(:password, :string)
    end

    def changeset(attrs \\ %{}) do
      %__MODULE__{}
      |> cast(attrs, [:email, :password])
      |> validate_required([:email, :password])
      |> validate_length(:email, min: 3)
      |> validate_length(:password, min: 8)
      |> validate_format(:email, ~r/@/)
    end

    def error_changeset(data) do
      data
      |> cast(%{}, [:email, :password])
      |> add_error(:password, "is invalid")
    end
  end

  @impl true
  def mount(_params, session, socket) do
    {:ok,
     assign(socket,
       connected: connected?(socket),
       changeset: LoginForm.changeset(),
       next_url: Map.get(session, "login_next_url", "/"),
       success: false,
       show_password: false
     )}
  end

  @impl true
  def handle_params(_, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "validate",
        %{"login_form" => attrs},
        socket
      ) do
    changeset =
      attrs
      |> LoginForm.changeset()

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event(
        "login",
        %{"login_form" => attrs},
        socket
      ) do
    attrs
    |> LoginForm.changeset()
    |> Ecto.Changeset.apply_action(:insert)
    |> case do
      {:ok, data} ->
        LoginForm.changeset(attrs)
        check_user(data, socket)

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_event("toggle_password", _, socket) do
    {:noreply, assign(socket, show_password: !socket.assigns.show_password)}
  end

  @impl true
  def handle_info({:redirect_to, url}, socket) do
    {:noreply, redirect(socket, to: url)}
  end

  defp check_user(%{email: email, password: password} = data, socket) do
    Account.check_user(email, password)
    |> case do
      {:ok, user} ->
        token =
          Phoenix.Token.sign(
            VacEngineWeb.Endpoint,
            "login_token",
            {user.id, socket.assigns.next_url}
          )

        url = Routes.auth_path(socket, :login, token)

        Process.send_after(
          self(),
          {:redirect_to, url},
          Application.get_env(:vac_engine, :login_delay)
        )

        {:noreply, assign(socket, success: true)}

      _ ->
        {:error, changeset} =
          LoginForm.error_changeset(data)
          |> Ecto.Changeset.apply_action(:insert)

        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
