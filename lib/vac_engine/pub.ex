defmodule VacEngine.Pub do
  @moduledoc """
  Publication manager
  """
  import Ecto.Query
  alias Ecto.Multi

  alias VacEngine.Repo
  alias VacEngine.Pub.Portal
  alias VacEngine.Pub.Cache
  alias VacEngine.Pub.Publication
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor
  alias VacEngine.Account.Workspace
  import VacEngine.PipeHelpers
  import VacEngine.EctoHelpers, only: [transaction: 2]

  # TODO change to reuse portal when possible
  @doc """
  Publish a blueprint.

  - create portal
  - create publication
  - set publication as active
  """
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
        {:ok, %{pub | portal: portal}}

      err ->
        err
    end
    |> tap_ok(&bust_cache/0)
  end

  @doc """
  Cast attributes into a changeset
  """
  def change_portal(data, attrs \\ %{}) do
    Portal.changeset(data, attrs)
  end

  @doc """
  Get a portal with id, raise if not found.
  """
  def get_portal!(id) do
    Repo.get!(Portal, id)
  end

  @doc """
  Delete portal
  """
  def delete_portal(portal) do
    Multi.new()
    |> Multi.delete_all(:delete_publications, fn _ ->
      from(r in Publication, where: r.portal_id == ^portal.id)
    end)
    |> Multi.delete(:delete_portal, portal)
    |> transaction(:delete_portal)
    |> tap_ok(&bust_cache/0)
  end

  @doc """
  Deactivate publication
  """
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

  @doc """
  List all portals
  """
  def list_portals() do
    from(p in Portal, preload: [:publications])
    |> Repo.all()
  end

  @doc """
  Run a processor and use cache
  """
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

  @doc """
  Get processor info and use cache
  """
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

  @doc """
  Bust cache only if blueprint is currently active
  """
  def bust_blueprint_cache(%Blueprint{} = blueprint) do
    from(p in Publication,
      where:
        p.blueprint_id == ^blueprint.id and
          is_nil(p.deactivated_at),
      select: count(p.id) > 1000
    )
    |> Repo.one()
    |> tap_on(true, &bust_cache/0)
  end

  @doc """
  Bust all cache
  """
  def bust_cache(), do: Cache.bust()

  @doc """
  Bust all cached permissions
  """
  def bust_api_keys_cache(), do: Cache.bust_api_keys()

  @doc """
  Load portals of workspace
  """
  def load_portals(%Workspace{} = workspace) do
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

    Repo.preload(workspace, [portals: portals_query], force: true)
  end

  @doc """
  Load publications of blueprint or portal
  """
  def load_publications(target) do
    publications_query =
      from(r in Publication,
        order_by: [desc: r.activated_at],
        preload: :portal
      )

    Repo.preload(target, [publications: publications_query], force: true)
  end

  @doc """
  Load active publication of portal
  """
  def load_active_publication(%Portal{} = portal) do
    publications_query =
      from(r in Publication,
        order_by: [desc: r.activated_at],
        where: is_nil(r.deactivated_at),
        preload: :portal,
        limit: 1
      )

    Repo.preload(portal, [active_publication: publications_query], force: true)
  end

  @doc """
  Load active publications of portal
  """
  def load_active_publications(%Blueprint{} = blueprint) do
    publications_query =
      from(r in Publication,
        order_by: [r.portal_id, desc: r.activated_at],
        where: is_nil(r.deactivated_at),
        preload: :portal
      )

    Repo.preload(blueprint, [active_publications: publications_query],
      force: true
    )
  end
end
