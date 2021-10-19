defmodule VacEngine.Pub.Cache do
  use GenServer

  alias VacEngine.Account
  alias VacEngine.Processor
  alias VacEngine.Pub.Cache

  defstruct api_keys: %{}, processors: %{}

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

  def refresh_api_keys() do
    GenServer.call(__MODULE__, :refresh_api_keys)
  end

  @impl true
  def init(_opts) do
    state = build_cache()

    {:ok, state}
  end

  @impl true
  def handle_call(:refresh, _from, _state) do
    state = build_cache()

    {:reply, :ok, state}
  end

  @impl true
  def handle_call(:refresh_api_keys, _from, state) do
    state = refresh_api_keys(state)

    {:reply, :ok, state}
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

  defp build_cache() do
    %Cache{}
    |> refresh_api_keys
  end

  defp refresh_api_keys(state) do
    keys =
      Account.list_api_keys()
      |> Enum.map(fn k ->
        %{id: id, prefix: _prefix, secret: secret} =
          Account.explode_composite_secret(k.secret)

        {id, %{secret: secret, portals: k.portals}}
      end)
      |> Map.new()

    %{state | api_keys: keys}
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
