defmodule VacEngineWeb.SimulationLive.VariableFullNameComponent do
  @moduledoc """
  Show variable name indented with dashes according its position in
  the structure.
  """

  use Phoenix.Component

  alias VacEngine.Processor.Variable

  def render(%{variable: %Variable{}} = assigns) do
    ~H"""
    <%= @variable.path
      |> Enum.drop(-1)
      |> Enum.map(fn _ -> "\u2574" end)
    %><span><%= @variable.name %></span>
    """
  end
end
