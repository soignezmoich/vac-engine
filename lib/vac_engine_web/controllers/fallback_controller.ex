defmodule VacEngineWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use VacEngineWeb, :controller

  def call(conn, :error), do: call(conn, {:error, :bad_request})
  def call(conn, {:error}), do: call(conn, {:error, :bad_request})

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> set_view()
    |> render(:"404")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> set_view()
    |> render(:"401")
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> set_view()
    |> render(:"403")
  end

  def call(conn, {:error, :bad_request, message}) do
    conn
    |> put_status(:bad_request)
    |> set_view()
    |> render(:"400", message: message)
  end

  def call(conn, {:error, :bad_request}) do
    conn
    |> put_status(:bad_request)
    |> set_view()
    |> render(:"400")
  end

  def call(conn, {:error, _err}) do
    conn
    |> put_status(:internal_server_error)
    |> set_view()
    |> render(:"500")
  end

  defp set_view(conn) do
    conn
    |> put_layout(false)
    |> put_root_layout(false)
    |> put_view(VacEngineWeb.ErrorView)
  end
end
