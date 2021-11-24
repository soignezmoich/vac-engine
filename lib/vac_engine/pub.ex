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
  """
  import Ecto.Query
  alias Ecto.Multi

  alias VacEngine.Repo
  alias VacEngine.Pub.Portal
  alias VacEngine.Pub.Cache
  alias VacEngine.Pub.Publication
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor
  import VacEngine.PipeHelpers
  import VacEngine.EctoHelpers, only: [transaction: 2]

  @doc """
  List all portals
  """
  def list_portals(queries \\ & &1) do
    Portal
    |> queries.()
    |> Repo.all()
  end

  @doc """
  Get a portal with id, raise if not found.
  """
  def get_portal!(id, queries \\ & &1) do
    Portal
    |> queries.()
    |> Repo.get!(id)
  end

  def filter_active_portals(query) do
    from(p in query,
      where: not is_nil(p.blueprint_id)
    )
  end

  def load_portal_publications(query) do
    publications_query =
      from(r in Publication,
        order_by: [desc: r.activated_at],
        preload: :blueprint
      )

    from(p in query, preload: [publications: ^publications_query])
  end

  def load_portal_blueprint(query) do
    from(p in query, preload: :blueprint)
  end

  def filter_portals_by_workspace(query, workspace) do
    from(p in query, where: p.workspace_id == ^workspace.id)
  end

  @doc """
  Publish a blueprint.

  - create portal
  - create publication
  - set publication as active

  First variant with existing portal

  Second variant with new portal params
  """
  def publish_blueprint(%Blueprint{} = br, %Portal{} = portal) do
    Multi.new()
    |> Multi.update_all(
      :deactivate,
      fn _ ->
        now = DateTime.truncate(DateTime.utc_now(), :second)

        from(p in Publication,
          where: p.portal_id == ^portal.id and is_nil(p.deactivated_at),
          update: [set: [deactivated_at: ^now]]
        )
      end,
      []
    )
    |> Multi.update(:portal, fn _ ->
      portal
      |> change_portal(%{})
      |> Ecto.Changeset.change(blueprint_id: br.id)
    end)
    |> Multi.insert(:publication, fn _ ->
      %Publication{
        workspace_id: br.workspace_id,
        blueprint_id: br.id,
        portal_id: portal.id
      }
      |> Publication.changeset(%{
        activated_at: NaiveDateTime.utc_now(),
        deactivated_at: nil
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

  def publish_blueprint(%Blueprint{} = br, portal_params) do
    Multi.new()
    |> Multi.insert_or_update(:portal, fn _ ->
      %Portal{
        workspace_id: br.workspace_id,
        interface_hash: br.interface_hash,
        blueprint_id: br.id
      }
      |> change_portal(portal_params)
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

  def unpublish_portal(%Portal{} = portal) do
    Multi.new()
    |> Multi.update_all(
      :deactivate,
      fn _ ->
        now = DateTime.truncate(DateTime.utc_now(), :second)

        from(p in Publication,
          where: p.portal_id == ^portal.id and is_nil(p.deactivated_at),
          update: [set: [deactivated_at: ^now]]
        )
      end,
      []
    )
    |> Multi.update(:portal, fn _ ->
      portal
      |> change_portal(%{})
      |> Ecto.Changeset.change(blueprint_id: nil)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{portal: portal}} ->
        {:ok, portal}

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
  Update portal with attributes
  """
  def update_portal(data, attrs \\ %{}) do
    data
    |> change_portal(attrs)
    |> Repo.update()
  end

  @doc """
  Cast attributes into a changeset
  """
  def create_portal(workspace, attrs \\ %{}) do
    %Portal{workspace_id: workspace.id}
    |> Portal.changeset(attrs)
    |> Repo.insert()
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
  Run a processor and use cache
  """
  def run_cached(
        %{api_key: _api_key, portal_id: _portal_id, input: input, env: _env} =
          args
      ) do
    with {:ok, processor, env} <- Cache.find_processor(args),
         {:ok, state} <- Processor.run(processor, input, env) do
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
      {:ok, processor, _env} ->
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
      select: count(p.id) > 0
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
end
