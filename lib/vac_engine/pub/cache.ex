defmodule VacEngine.Pub.Cache do
  use GenServer

  import Ecto.Query
  alias VacEngine.Repo
  alias VacEngine.Account
  alias VacEngine.Processor
  alias VacEngine.Pub.Cache

  @check_interval Application.compile_env!(:vac_engine, :cache_check_interval)

  defstruct api_keys: %{},
            processors: %{},
            blueprints_version: 0,
            api_keys_version: 0

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def find_processor(%{api_key: _api_key, portal_id: _pid} = data) do
    GenServer.call(__MODULE__, {:find_processor, data})
  end

  def find_processor(_), do: :error

  def bust() do
    GenServer.call(__MODULE__, :bust)
  end

  def bust_api_keys() do
    GenServer.call(__MODULE__, :bust_api_keys)
  end

  @impl true
  def init(_opts) do
    send(self(), :check_version)

    {:ok, %Cache{}}
  end

  @impl true
  def handle_call(:bust, _from, cache) do
    {:ok, %{rows: [[api_keys_version]]}} =
      "SELECT nextval('pub_cache_api_keys_version')"
      |> Repo.query()

    {:ok, %{rows: [[blueprints_version]]}} =
      "SELECT nextval('pub_cache_blueprints_version')"
      |> Repo.query()

    cache =
      %{
        cache
        | api_keys_version: api_keys_version,
          blueprints_version: blueprints_version
      }
      |> refresh()
      |> refresh_api_keys()

    {:reply, :ok, cache}
  end

  @impl true
  def handle_call(:bust_api_keys, _from, cache) do
    {:ok, %{rows: [[api_keys_version]]}} =
      "SELECT nextval('pub_cache_api_keys_version')"
      |> Repo.query()

    cache =
      %{
        cache
        | api_keys_version: api_keys_version
      }
      |> refresh_api_keys()

    {:reply, :ok, cache}
  end

  @impl true
  def handle_call(
        {:find_processor, %{api_key: api_key, portal_id: portal_id}},
        _from,
        state
      ) do
    with {:ok, portal_id} <- flex_integer(portal_id),
         %{id: id, prefix: _prefix, secret: req_secret} <-
           Account.explode_composite_secret(api_key),
         %{portals: portals, secret: secret} <- Map.get(state.api_keys, id),
         true <- Plug.Crypto.secure_compare(req_secret, secret),
         %{blueprint_id: blueprint_id} <- Map.get(portals, portal_id),
         {:ok, state} <- ensure_processor_loaded(state, blueprint_id) do
      proc =
        state
        |> get_in([Access.key(:processors), blueprint_id])

      {:reply, {:ok, proc}, state}
    else
      _ ->
        {:reply, {:error, :not_found}, state}
    end
  end

  @impl true
  def handle_info(:check_version, cache) do
    api_keys_version =
      from(v in "pub_cache_api_keys_version", select: v.last_value)
      |> Repo.one()

    blueprints_version =
      from(v in "pub_cache_blueprints_version", select: v.last_value)
      |> Repo.one()

    cache =
      cond do
        blueprints_version > cache.blueprints_version ->
          %{
            cache
            | api_keys_version: api_keys_version,
              blueprints_version: blueprints_version
          }
          |> refresh()
          |> refresh_api_keys()

        api_keys_version > cache.api_keys_version ->
          %{cache | api_keys_version: api_keys_version}
          |> refresh_api_keys()

        true ->
          cache
      end

    Process.send_after(self(), :check_version, @check_interval)
    {:noreply, cache}
  end

  defp refresh(cache) do
    %{cache | processors: %{}}
  end

  defp refresh_api_keys(cache) do
    Account.list_api_keys()
    |> Enum.map(fn k ->
      %{id: id, prefix: _prefix, secret: secret} =
        Account.explode_composite_secret(k.secret)

      {id, %{secret: secret, portals: k.portals}}
    end)
    |> Map.new()
    |> then(fn keys ->
      %{cache | api_keys: keys}
    end)
  end

  defp ensure_processor_loaded(state, blueprint_id) do
    state
    |> get_in([Access.key(:processors), blueprint_id])
    |> case do
      nil ->
        blueprint_id
        |> Processor.get_blueprint!()
        |> Processor.compile_blueprint()
        |> case do
          {:ok, proc} ->
            {:ok, put_in(state, [Access.key(:processors), blueprint_id], proc)}

          err ->
            err
        end

      _p ->
        {:ok, state}
    end
  end

  defp flex_integer(i) when is_integer(i), do: i

  defp flex_integer(i) when is_binary(i) do
    i
    |> Integer.parse()
    |> case do
      {i, _} -> {:ok, i}
      _ -> {:error, "invalid integer"}
    end
  end
end
