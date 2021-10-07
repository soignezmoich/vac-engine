defmodule VacEngineWeb.Api.PubController do
  use VacEngineWeb, :controller
  alias VacEngine.Pub

  action_fallback(VacEngineWeb.Api.FallbackController)

  def run(conn, %{"portal_id" => portal_id, "input" => input}) do
    api_key = conn.assigns.api_key

    with {:ok, result} <-
           Pub.run_cached(%{
             input: input,
             api_key: api_key,
             portal_id: portal_id
           }) do
      render(conn, "result.json", result: result)
    else
      {:error, msg} ->
        {:error, :bad_request, msg}

      err ->
        {:error, :bad_request}
    end
  end

  def run(conn, _) do
    {:error, :bad_request, "portal_id and input required"}
  end
end
