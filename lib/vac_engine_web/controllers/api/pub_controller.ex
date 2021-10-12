defmodule VacEngineWeb.Api.PubController do
  use VacEngineWeb, :controller
  alias VacEngine.Pub

  action_fallback(VacEngineWeb.Api.FallbackController)

  def run(conn, %{"portal_id" => portal_id, "input" => input})
      when is_binary(portal_id) do
    portal_id
    |> Integer.parse()
    |> case do
      {portal_id, _} ->
        run(conn, %{"portal_id" => portal_id, "input" => input})

      :error ->
        {:error, :bad_request, "invalid portal_id"}
    end
  end

  def run(conn, %{"portal_id" => portal_id, "input" => input}) do
    api_key = conn.assigns.api_key

    %{
      input: input,
      api_key: api_key,
      portal_id: portal_id
    }
    |> Pub.run_cached()
    |> case do
      {:ok, result} ->
        render(conn, "result.json", result: result)

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
