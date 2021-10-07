defmodule VacEngineWeb.Api.PubController do
  use VacEngineWeb, :controller
  alias VacEngine.Pub

  action_fallback(VacEngineWeb.Api.FallbackController)

  def run(conn, %{"portal_id" => portal_id, "input" => input})
      when is_binary(portal_id) do
    with {portal_id, _} <- Integer.parse(portal_id) do
      run(conn, %{"portal_id" => portal_id, "input" => input})
    else
      :error ->
        {:error, :bad_request, "invalid portal_id"}
    end
  end

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

      _err ->
        {:error, :bad_request}
    end
  end

  def run(_conn, _) do
    {:error, :bad_request, "portal_id and input required"}
  end
end
