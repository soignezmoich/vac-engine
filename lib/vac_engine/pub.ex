defmodule VacEngine.Pub do
  import Ecto.Query
  alias Ecto.Multi

  alias VacEngine.Repo
  alias VacEngine.Pub.Portal
  alias VacEngine.Pub.Cache
  alias VacEngine.Pub.Publication
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor

  # TODO change to reuse portal when possible
  def publish_blueprint(%Blueprint{} = br) do
    Multi.new()
    |> Multi.insert(:portal, fn _ ->
      %Portal{
        name: br.name,
        interface_hash: br.interface_hash,
        workspace_id: br.workspace_id
      }
      |> Portal.changeset(%{})
    end)
    |> Multi.insert(:publication, fn %{portal: portal} ->
      %Publication{
        workspace_id: br.workspace_id,
        blueprint_id: br.id,
        portal_id: portal.id
      }
      |> Publication.changeset(%{
        activated_at: NaiveDateTime.utc_now()
      })
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{publication: pub, portal: portal}} ->
        {:ok, %{pub | portal: portal}}

      err ->
        err
    end
  end

  def list_portals() do
    from(p in Portal, preload: [:publications])
    |> Repo.all()
  end

  def refresh_cache(), do: Cache.refresh()
  def refresh_cache_api_keys(), do: Cache.refresh_api_keys()

  def run_cached(
        %{api_key: _api_key, portal_id: _portal_id, input: input} = args
      ) do
    with {:ok, processor} <- Cache.find_processor(args),
         {:ok, state} <- Processor.run(processor, input) do
      {:ok, %{output: state.output, input: state.input}}
    else
      {:error, msg} -> {:error, msg}
      _err -> {:error, "cannot run processor"}
    end
  end

  def run_cached(_), do: :error

  def active_publication(%Portal{} = portal) do
    portal.publications
    |> Enum.find(fn pub ->
      pub.deactivated_at == nil
    end)
  end
end
