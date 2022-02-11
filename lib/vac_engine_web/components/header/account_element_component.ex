defmodule VacEngineWeb.Header.AccountElementComponent do
  use VacEngineWeb, :component

  import VacEngineWeb.Header.MenuComponent
  import VacEngineWeb.Header.TopElementComponent
  import VacEngineWeb.IconComponent

  alias VacEngineWeb.Endpoint

  def account_element(%{role: nil} = assigns) do
    attrs = %{
      l: "Login",
      a: Routes.login_path(Endpoint, :form),
      s: false,
      i: "hero/login"
    }

    assigns = assign(assigns, attrs: attrs)

    ~H"""
    <.top_element {@attrs} />
    """
  end

  def account_element(%{role: _role} = assigns) do
    ~H"""
    <div class="relative font-normal flex w-12 h-12 shadow-md item-center justify-center
      text-sm mx-1 my-1 px-2 pt-1.5 text-gray-50 rounded-full
      cursor-pointer bg-blue-800 hover:bg-blue-700 border border-blue-500"
      id="account-dropdown-menu"
      data-dropdown="account-dropdown"
      >
      <.icon name="hero/user" width="2rem" />
    </div>
    <.menu {assigns} />
    """
  end
end
