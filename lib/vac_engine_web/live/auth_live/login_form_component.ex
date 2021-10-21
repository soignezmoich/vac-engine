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
        phx_throttle="100"
        phx_change="validate"
        phx_submit="login"
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
          class: "h-8 bg-gray-100 text-gray-900 px-2 py-1 focus:outline-blue
                 #{if has_error?(@f, :email) do "bg-red-150" end}",
          autofocus: true %>
    """
  end

  defp password_field(assigns) do
    ~H"""
    <div class="relative flex">
      <%= if @visible do %>
        <%= text_input @f, :password, value: input_value(@f, :password),
            class: "h-8 bg-gray-100 text-gray-900 px-2 py-1 focus:outline-blue
                    pr-16 h-8
                    #{if has_error?(@f, :password) do "bg-red-150" end}" %>
      <% else %>
        <%= password_input @f, :password, value: input_value(@f, :password),
            class: "h-8 bg-gray-100 text-gray-900 px-2 py-1 focus:outline-blue
                    pr-16 h-8
                    #{if has_error?(@f, :password) do "bg-red-150" end}" %>
      <% end %>
      <div phx-click="toggle_password"
        phx-hook="focus"
        id="toggle_password"
        data-focus="login_form_password"
        class="absolute right-0 top-0 py-1 px-2 bg-gray-200 h-8 flex
               items-center text-cream-600">
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
