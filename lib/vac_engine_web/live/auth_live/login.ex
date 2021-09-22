defmodule VacEngineWeb.AuthLive.Login do
  use Phoenix.LiveView,
    container: {:div, class: "flex flex-col max-w-full min-w-full"}

  alias VacEngineWeb.AuthView
  alias VacEngine.Accounts
  alias VacEngineWeb.Router.Helpers, as: Routes

  @impl true
  def render(assigns), do: AuthView.render("login.html", assigns)

  @impl true
  def mount(_params, session, socket) do
    {:ok,
     assign(socket,
       email: nil,
       password: nil,
       show_password: false,
       next_url: Map.get(session, "login_next_url", "/"),
       password_error: false,
       email_error: false,
       login_disabled: true,
       success: false
     )}
  end

  @impl true
  def handle_params(_, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "validate",
        %{"credentials" => %{"email" => email, "password" => password}},
        socket
      ) do
    {:noreply,
     assign(socket,
       email: email,
       password: password,
       email_error: false,
       password_error: false,
       login_disabled: String.length(email) <= 3 || String.length(password) <= 6
     )}
  end

  @impl true
  def handle_event(
        "login",
        %{"credentials" => %{"email" => email, "password" => password}},
        socket
      ) do
    if !String.match?(email, ~r/.*@.*/) do
      {:noreply,
       assign(socket,
         email: email,
         password: password,
         email_error: true,
         password_error: false,
         login_disabled: true
       )}
    else
      with {:ok, user} <- Accounts.check_user(email, password) do
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
      else
        _ ->
          {:noreply,
           assign(socket,
             email: email,
             password: password,
             email_error: false,
             password_error: true,
             login_disabled: true
           )}
      end
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
end
