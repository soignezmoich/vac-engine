defmodule VacEngine.Pub do
  import Ecto.Query
  alias Ecto.Multi

  alias VacEngine.Repo
  alias VacEngine.Pub.Portal
  alias VacEngine.Pub.Cache
  alias VacEngine.Pub.Publication
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor
  alias VacEngine.Account.Workspace
  alias VacEngine.Account.Role

  # TODO change to reuse portal when possible
  def publish_blueprint(%Blueprint{} = br, attrs \\ %{}) do
    Multi.new()
    |> Multi.insert(:portal, fn _ ->
      %Portal{
        name: br.name,
        interface_hash: br.interface_hash,
        workspace_id: br.workspace_id
      }
      |> Portal.changeset(attrs)
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
        refresh_cache()
        {:ok, %{pub | portal: portal}}

      err ->
        err
    end
  end

  def change_portal(data, attrs \\ %{}) do
    Portal.changeset(data, attrs)
  end

  def get_portal!(id) do
    Repo.get!(Portal, id)
  end

  def delete_portal(portal) do
    Multi.new()
    |> Multi.delete_all(:delete_publications, fn _ ->
      from(r in Publication, where: r.portal_id == ^portal.id)
    end)
    |> Multi.delete(:delete_portal, portal)
    |> Repo.transaction()
    |> case do
      {:ok, _} -> {:ok, portal}
      {:error, _, err, _} -> {:error, err}
    end
  end

  def deactivate_publication(%Publication{} = pub) do
    from(p in Publication,
      where: p.id == ^pub.id,
      update: [set: [deactivated_at: fragment("now() at time zone 'utc'")]]
    )
    |> Repo.update_all([])
    |> case do
      {1, _} ->
        {:ok, pub}

      _ ->
        {:error, "publication not found "}
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

  def info_cached(%{api_key: _api_key, portal_id: _portal_id} = args) do
    args
    |> Cache.find_processor()
    |> case do
      {:ok, processor} ->
        {:ok, processor.info}

      {:error, msg} ->
        {:error, msg}

      _err ->
        {:error, "cannot run processor"}
    end
  end

  def info_cached(_), do: :error

  def active_publications(%Portal{} = portal) do
    portal.publications
    |> Enum.find(fn pub ->
      pub.deactivated_at == nil
    end)
  end

  def load_portals(%Workspace{} = workspace, force \\ false) do
    publications_query =
      from(r in Publication,
        order_by: [desc: r.activated_at],
        preload: :portal
      )

    portals_query =
      from(r in Portal,
        order_by: [desc: r.inserted_at],
        preload: [publications: ^publications_query]
      )

    Repo.preload(workspace, [portals: portals_query], force: force)
  end

  def load_publications(target, force \\ false)

  def load_publications(%Blueprint{} = blueprint, force) do
    publications_query =
      from(r in Publication,
        order_by: [desc: r.activated_at],
        preload: :portal
      )

    Repo.preload(blueprint, [publications: publications_query], force: force)
  end

  def load_publications(%Portal{} = portal, force) do
    publications_query =
      from(r in Publication,
        order_by: [desc: r.activated_at],
        preload: :portal
      )

    Repo.preload(portal, [publications: publications_query], force: force)
  end
end
