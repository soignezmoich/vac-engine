defmodule VacEngineWeb.SimulationLive.InputComponent do
  @moduledoc false

  use Phoenix.Component

  def boolean_input(assigns) do
    ~H"""
      <select class="form-fld text-sm">
        <option selected={@value == true}>true</option>
        <option selected={@value == false}>false</option>
      </select>
    """
  end

  def number_input(assigns) do
    ~H"""
     <input type="number" class="form-fld text-sm" value={@value} />
    """
  end

  def integer_input(assigns) do
    ~H"""
     <input type="number" class="form-fld text-sm" value={@value} />
    """
  end

  def string_input(assigns) do
    ~H"""
     <input class="form-fld text-sm" value={@value} />
    """
  end

  def date_input(assigns) do
    ~H"""
    <input class="form-fld text-sm" placeholder="1990-10-10" value={@value} />
    """
  end

  def datetime_input(assigns) do
    ~H"""
    <input class="form-fld text-sm" placeholder="1990-10-10 14:10:45" value={@value} />
    """
  end
end
