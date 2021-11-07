defmodule VacEngine.Pub do
  @moduledoc """
  Provides a publication manager to allow processors to be
  accessible through the API.

  ## Portals

  Portals are the access points of the application. Each portal
  is responsible to give access to a single processor through the API.
  Therefore, a protal has a reference exactly one blueprint in
  the api. The reference is called a "publication".

  Interface to consume a portal is made of a pair of calls:
  - the`run_cached/1` function and
  - the `info_cached/1`function


  #### Run function

  Runs the linked processor on the given input, using the provided api_key
  to authenticate:

      {:ok, %{input: input, output: output}} =
        Pub.run_cached(%{api_key: api_key, portal_id: portal_id, input: input})

  Note that the in-memory compiled processor is used as indicated by the
  *cached* suffix.

  #### Info function

  Gets the description of the processor linked to the portal

      {:ok, %{input: input_schema, output: output_schema, logic: logic}} =
        Pub.info_cached(%{api_key: api_key, portal_id: portal_id})

  Again, the in-memory compiled processor is used.

  > *Note: The decription of the corresponding API endpoints is available
  > in the swagger documentation at `/priv/static/docs/api.html`.*

  ## Publications

  A publication links a processor to a portal. The same processor can be
  published several times, but a portal can have only one active publication
  at a time.

  #### Create a publication

  Since a portal must give access to exactly processor, publication
  is always made with a blueprint as parameter in the `publish_blueprint/2`
  function. This function returns the corresponding publication:

      {:ok, publication} = Pub.publish_blueprint()

  #### Publication deactivation

  Publication can be deactivated using the `deactivate_publication/1`. This
  is necessary if you want to publish a new form to a given portal.

  #### Cache management

  As stated above, blueprints are stored in cache. API keys are also stored in
  cache. It is the responsibility of the consumer to refresh the cache when
  corresponding data should be updated (e.g. when new blueprint is associated
  to the portal, when the linked blueprint is modified or when the API keys
  are modified). This can be done using the `bust_cache/0`, the
  `bust_blueprint_cache/0` and `bust_api_keys_cache/0` funtions.

  TODO not possible to reactivate??
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
  TODO remove
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
  TODO remove
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
  TODO remove
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
