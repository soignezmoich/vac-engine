defmodule VacEngineWeb.Api.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use VacEngineWeb, :controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> set_view()
    |> render("error.json", error: "resource not found")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> set_view()
    |> render("error.json", error: "unauthorized, authorization header missing")
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> set_view()
    |> render("error.json", error: "forbidden")
  end

  def call(conn, {:error, :bad_request, message}) do
    conn
    |> put_status(:bad_request)
    |> set_view()
    |> render("error.json", error: message)
  end

  def call(conn, {:error, :bad_request}) do
    conn
    |> put_status(:bad_request)
    |> set_view()
    |> render("error.json", error: "bad request")
  end

  def call(conn, {:error, _err}) do
    conn
    |> put_status(:internal_server_error)
    |> set_view()
    |> render("error.json", error: "internal server error")
  end

  defp set_view(conn) do
    conn
    |> put_view(VacEngineWeb.Api.ErrorView)
  end
end
