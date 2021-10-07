defmodule VacEngine.Pub.Cache do
  use GenServer

  alias VacEngine.Account
  alias VacEngine.Pub
  alias VacEngine.Pub.Cache
  alias VacEngine.Processor

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def find_processor(%{api_key: _api_key, portal_id: _pid} = data) do
    GenServer.call(__MODULE__, {:find_processor, data})
  end

  def find_processor(_), do: :error

  def refresh() do
    GenServer.call(__MODULE__, :refresh)
  end

  def load_blueprint(blueprint_id) do
  end

  @impl true
  def init(opts) do
    state = build_cache()

    {:ok, state}
  end

  @impl true
  def handle_call(:refresh, _from, state) do
    state = build_cache()

    {:reply, :ok, state}
  end

  @impl true
  def handle_call(
        {:find_processor, %{api_key: api_key, portal_id: pid}},
        _from,
        state
      ) do
    with %{id: id, prefix: prefix, secret: req_secret} <-
           Account.explode_composite_secret(api_key),
         %{portals: portals, secret: secret} <- Map.get(state.api_keys, id),
         true <- Plug.Crypto.secure_compare(req_secret, secret),
         %{blueprint_id: blueprint_id} <- Map.get(portals, pid) do
      state = ensure_processor_loaded(state, blueprint_id)

      proc =
        state
        |> get_in([:processors, blueprint_id])

      {:reply, {:ok, proc}, state}
    else
      _ ->
        {:reply, {:error, :not_found}, state}
    end
  end

  defp build_cache() do
    keys =
      Account.list_api_keys()
      |> Enum.map(fn k ->
        %{id: id, prefix: prefix, secret: secret} =
          Account.explode_composite_secret(k.secret)

        {id, %{secret: secret, portals: k.portals}}
      end)
      |> Map.new()

    %{
      api_keys: keys,
      processors: %{}
    }
  end

  defp ensure_processor_loaded(state, blueprint_id) do
    state
    |> get_in([:processors, blueprint_id])
    |> case do
      nil ->
        {:ok, proc} =
          blueprint_id
          |> Processor.get_blueprint!()
          |> Processor.compile_blueprint()

        put_in(state, [:processors, blueprint_id], proc)

      p ->
        state
    end
  end
end
