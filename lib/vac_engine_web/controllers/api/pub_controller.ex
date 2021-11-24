defmodule VacEngineWeb.Api.PubController do
  use VacEngineWeb, :controller
  alias VacEngine.Pub
  require Logger

  action_fallback(VacEngineWeb.Api.FallbackController)

  def run(conn, %{"portal_id" => portal_id, "input" => input} = params) do
    api_key = conn.assigns.api_key

    %{
      input: input,
      api_key: api_key,
      portal_id: portal_id,
      env: Map.get(params, "env", %{})
    }
    |> Pub.run_cached()
    |> case do
      {:ok, result} ->
        render(conn, "run.json", result: result)

      {:error, :not_found} ->
        {:error, :not_found, "api key or portal not found"}

      {:error, msg} ->
        Logger.warning("Bad request: #{msg}")
        Logger.warning("Input: #{inspect(input)}")
        {:error, :bad_request, msg}

      _err ->
        Logger.error("Run error")
        {:error, :bad_request}
    end
  end

  def run(_conn, _) do
    {:error, :bad_request, "portal_id and input required"}
  end

  def info(conn, %{"portal_id" => portal_id}) do
    api_key = conn.assigns.api_key

    %{
      api_key: api_key,
      portal_id: portal_id,
      env: Map.get(params, "env", %{})
    }
    |> Pub.info_cached()
    |> case do
      {:ok, info} ->
        render(conn, "info.json", info: info)

      {:error, msg} ->
        {:error, :bad_request, msg}

      _err ->
        {:error, :bad_request}
    end
  end
end
