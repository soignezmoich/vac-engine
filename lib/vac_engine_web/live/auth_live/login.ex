defmodule VacEngineWeb.AuthLive.Login do
  use VacEngineWeb, :live_view

  import VacEngine.PipeHelpers
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
    step =
      if connected?(socket) do
        :login_form
      else
        :loading
      end

    socket
    |> assign(
      changeset: LoginForm.changeset(),
      next_url: Map.get(session, "login_next_url", "/"),
      step: step,
      show_password: false
    )
    |> ok()
  end

  @impl true
  def handle_params(_, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "login_validate",
        %{"login_form" => attrs},
        socket
      ) do
    changeset =
      attrs
      |> LoginForm.changeset()

    socket
    |> assign(changeset: changeset)
    |> noreply()
  end

  @impl true
  def handle_event(
        "login_submit",
        %{"login_form" => attrs},
        socket
      ) do
    attrs
    |> LoginForm.changeset()
    |> Ecto.Changeset.apply_action(:insert)
    |> case do
      {:ok, data} ->
        check_user(data, socket)

      {:error, changeset} ->
        socket
        |> assign(changeset: changeset)
        |> noreply()
    end
  end

  @impl true
  def handle_event("toggle_password", _, socket) do
    socket
    |> assign(show_password: !socket.assigns.show_password)
    |> noreply()
  end

  @impl true
  def handle_event(
        "totp_validate",
        %{"totp" => %{"code" => code}},
        %{assigns: %{user: user}} = socket
      ) do
    secret = user.totp_secret || socket.assigns.totp_secret

    if String.length(code) == 6 do
      if NimbleTOTP.valid?(secret, code) do
        {:ok, user} = Account.update_user(user, %{totp_secret: secret})

        socket
        |> login_success(user)
        |> noreply()
      else
        socket
        |> assign(totp_error: true)
        |> noreply()
      end
    else
      socket
      |> assign(totp_error: false)
      |> noreply()
    end
  end

  @impl true
  def handle_event(
        "totp_skip",
        _,
        %{assigns: %{user: user}} = socket
      ) do
    socket
    |> login_success(user)
    |> noreply()
  end

  @impl true
  def handle_info({:redirect_to, url}, socket) do
    socket
    |> redirect(to: url)
    |> noreply()
  end

  defp check_user(%{email: email, password: password} = data, socket) do
    Account.check_user(email, password)
    |> case do
      {:ok, %{totp_secret: nil} = user} ->
        {url, secret} = Account.gen_totp(user)
        svg = url |> EQRCode.encode() |> EQRCode.svg(width: 400)

        socket
        |> assign(
          step: :totp_setup,
          user: user,
          totp_svg: svg,
          totp_error: false,
          totp_secret: secret
        )
        |> noreply()

      {:ok, %{totp_secret: _secret} = user} ->
        socket
        |> assign(
          step: :totp_check,
          user: user,
          totp_error: false
        )
        |> noreply()

      _ ->
        {:error, changeset} =
          LoginForm.error_changeset(data)
          |> Ecto.Changeset.apply_action(:insert)

        socket
        |> assign(changeset: changeset)
        |> noreply()
    end
  end

  defp login_success(socket, user) do
    token =
      Phoenix.Token.sign(
        VacEngineWeb.Endpoint,
        "login_token",
        {user.id, socket.assigns.next_url}
      )

    url = Routes.login_path(socket, :login, token)

    Process.send_after(
      self(),
      {:redirect_to, url},
      Application.get_env(:vac_engine, :login_delay)
    )

    socket |> assign(step: :success)
  end
end
