defmodule VacEngineWeb.HeaderComponent do
  use VacEngineWeb, :component

  import VacEngineWeb.Header.AccountElementComponent
  import VacEngineWeb.Header.SubElementComponent
  import VacEngineWeb.Header.TitleComponent
  import VacEngineWeb.Header.TopElementComponent
  import VacEngineWeb.VersionHelpers

  def header(assigns) do
    ~H"""
    <header class="flex flex-col lg:flex-row relative bg-blue-700">
      <nav class="flex mx-2  xl:self-stretch
                  items-stretch h-14">
        <.top_level {assigns} />
        <div class="flex whitespace-nowrap pl-4 pr-1 font-bold items-center justify-center text-xl text-white italic truncate">
          <.title {assigns} />
        </div>
      </nav>

      <%= if length(sub_elements(assigns)) > 0 do %>
        <.filler_without_build_info />
        <.sub_level {assigns} />
      <% else %>
        <.filler_with_build_info />
      <% end %>
    </header>
    """
  end

  def top_level(assigns) do
    ~H"""
    <.account_element
      role={@role}
      workspace={@workspace}
      workspaces={@workspaces} />

    <%= for attrs <- top_elements(assigns) do %>
      <.top_element {attrs} />
    <% end %>
    """
  end

  def sub_level(assigns) do
    ~H"""
    <div class="text-cream-50 hidden lg:flex -mr-1">
      <svg width={"3.5rem"}
        height={"3.5rem"}
        viewBox="0 0 200 200">
        <use href={"/slope.svg#slope"}></use>
      </svg>
    </div>
    <nav class="flex bg-cream-50 min-w-full lg:min-w-fit px-2">
      <%= for attrs <- sub_elements(assigns) do %>
        <.sub_element {attrs} />
      <% end %>
    </nav>
    """
  end

  def filler_without_build_info(assigns) do
    ~H"""
    <div class="hidden lg:flex flex-grow" />
    """
  end

  def filler_with_build_info(assigns) do
    ~H"""
    <div class="hidden lg:flex flex-grow bg-blue-700 h-14">
      <div class="absolute top-0 right-0 py-1 px-3 text-xs text-gray-200">
        Version: <%= version() %>.
        Build date: <%= build_date() %>.
      </div>
    </div>
    """
  end
end
