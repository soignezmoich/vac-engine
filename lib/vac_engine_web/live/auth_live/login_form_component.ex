defmodule VacEngineWeb.AuthLive.LoginFormComponent do
  use VacEngineWeb, :component

  def login_form(assigns) do
    ~H"""
    <div class="bg-white border p-2 flex flex-col">
      <h1 class="font-bold text-2xl text-center">Login</h1>
      <.form
        let={f}
        for={@changeset}
        id="login_form"
        phx-throttle="100"
        phx-change="login_validate"
        phx-submit="login_submit"
        class="flex flex-col w-full">
        <.login_label f={f} field={:email} name="Email" />
        <.email_field f={f} />
        <.login_label f={f} field={:password} name="Password" />
        <.password_field f={f} visible={@show_password} />
        <.submit_button />
      </.form>
    </div>
    """
  end

  def totp_check_form(assigns) do
    ~H"""
    <div class="bg-white border p-2 flex flex-col max-w-md">
      <h1 class="font-bold text-2xl text-center mb-4">TOTP check</h1>
      <div class="p-2 text-center font-bold">
        Enter your 6 digits code below
      </div>
      <.form
        let={f}
        for={:totp}
        id="totp_code_form"
        phx-change="totp_validate"
        phx-submit="totp_validate"
        class="flex flex-col w-full items-center">
        <%= text_input f, :code,
            class: "code-fld mx-8",
            autocomplete: "off",
            phx_hook: "focusOnMount"
        %>

        <div class="flex h-8">
          <%= if @error do %>
            <div class="text-red-600 font-bold my-1">Code is invalid</div>
          <% end %>
        </div>
      </.form>
    </div>
    """
  end

  def totp_setup_form(assigns) do
    ~H"""
    <div class="bg-white border p-2 flex flex-col max-w-md">
      <h1 class="font-bold text-2xl text-center mb-4">TOTP setup</h1>
      <div class="text-sm p-2">
        Your account TOTP setup is not complete. To finalize the TOTP setup,
        please scan the QR code below with your authenticator app and enter the
        provided code below.
      </div>
      <div class="flex justify-center my-8">
        <%= raw @svg %>
      </div>
      <div class="p-2 text-center font-bold">
        Enter the provided 6 digits code below
      </div>
      <.form
        let={f}
        for={:totp}
        id="totp_code_form"
        phx-change="totp_validate"
        phx-submit="totp_validate"
        class="flex flex-col w-full items-center">

        <%= text_input f, :code,
            class: "code-fld mx-8",
            autocomplete: "off",
            phx_hook: "focusOnMount"
        %>

        <%= if @error do %>
          <div class="text-red-600 font-bold mt-1">Code is invalid</div>
        <% end %>
      </.form>
      <button class="btn-sm mt-8 self-center" phx-click="totp_skip">
        Skip for now
      </button>
    </div>
    """
  end

  defp login_label(assigns) do
    ~H"""
    <div class="flex w-full mt-6 mb-1 items-baseline">
      <%= if has_error?(@f, @field) do %>
      <%= label @f, @field, @name,
        class: "text-sm uppercase text-red-600 italic font-medium" %>
      <span class="text-red-600 text-xs italic">
         — <%= field_error(@f, @field) %>
      </span>
      <% else %>
      <%= label @f, @field, @name,
          class: "text-sm uppercase text-gray-800 font-medium" %>
      <% end %>
    </div>
    """
  end

  defp email_field(assigns) do
    ~H"""
    <%= text_input @f, :email,
          class: "h-8 form-fld
                 #{if has_error?(@f, :email) do "bg-red-150" end}",
          autofocus: true %>
    """
  end

  defp password_field(assigns) do
    ~H"""
    <div class="relative flex">
      <%= if @visible do %>
        <%= text_input @f, :password, value: input_value(@f, :password),
            style: "padding-right: 4rem",
            class: "h-8 form-fld
                    #{if has_error?(@f, :password) do "bg-red-150" end}" %>
      <% else %>
        <%= password_input @f, :password, value: input_value(@f, :password),
            style: "padding-right: 4rem",
            class: "h-8 form-fld
                    #{if has_error?(@f, :password) do "bg-red-150" end}" %>
      <% end %>
      <div phx-click="toggle_password"
        phx-hook="focus"
        id="toggle_password"
        data-focus="login_form_password"
        class="absolute right-px top-px py-1 px-2 bg-blue-100 bottom-px flex
               items-center text-cream-800">
        <svg height="24px"
          width="24px"
          viewBox="0 0 100 100">
          <%= if @visible do %>
          <use href="/icons/eye_crossed.svg#icon"></use>
          <% else %>
          <use href="/icons/eye.svg#icon"></use>
          <% end %>
        </svg>
      </div>
    </div>
    """
  end

  def submit_button(assigns) do
    ~H"""
    <%= submit class: "mt-10 h-8 flex items-stretch w-full
                       font-bold focus:outline-blue" do %>
    <span class="loading-hide w-full bg-blue-600 text-gray-100
                 flex justify-center items-center">Login</span>
    <div class="loading-show w-full bg-gray-700 text-gray-100
                 flex justify-center items-center">
      <svg height="30px"
        width="30px"
        viewBox="0 0 100 100">
        <use href="/icons/loading_spinner_simple.svg#icon"></use>
      </svg>
      <span class="ml-1">Login in progress…</span>
    </div>
    <% end %>
    """
  end
end
