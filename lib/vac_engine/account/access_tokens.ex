defmodule VacEngine.Account.AccessTokens do
  @moduledoc false

  import Ecto.Query
  alias Ecto.Multi
  alias VacEngine.Repo
  alias VacEngine.Account
  alias VacEngine.Pub
  alias VacEngine.Account.AccessToken
  alias VacEngine.Account.Role
  import VacEngine.EctoHelpers, only: [transaction: 2]
  import VacEngine.Account, only: [bust_role_cache: 1]
  import VacEngine.PipeHelpers

  def generate_secret(length \\ 16) do
    :crypto.strong_rand_bytes(length) |> Base24.encode24()
  end

  def generate_composite_secret(prefix, id) when is_integer(id) do
    id = Bitwise.bxor(0x76616365, id)
    id = <<id::little-signed-32>>
    id = Base24.encode24(id)

    if id == :error do
      raise "base24 encode failed"
    end

    sec = generate_secret(48)

    [prefix, id, sec]
    |> Enum.join("_")
    |> String.downcase()
  end

  def explode_composite_secret(secret) when is_binary(secret) do
    secret
    |> String.split("_")
    |> case do
      [prefix, id, secret] ->
        case Base24.decode24(id) do
          :error ->
            :error

          id ->
            <<id::little-signed-integer-size(32)>> = id
            id = Bitwise.bxor(0x76616365, id)
            %{id: id, prefix: prefix, secret: secret}
        end

      _ ->
        :error
    end
  end

  def create_api_token(%Role{} = role, is_test_key) do
    prefix =
      if is_test_key do
        :test
      else
        :api
      end

    secret = generate_composite_secret(prefix, role.id)

    Multi.new()
    |> Multi.insert(:token, fn _ ->
      %AccessToken{role_id: role.id, type: :api_key, secret: secret}
      |> AccessToken.changeset()
    end)
    |> transaction(:token)
    |> tap_ok(&bust_role_cache/1)
  end

  def list_api_tokens(queries \\ & &1) do
    from(t in AccessToken,
      where: t.type == :api_key,
      order_by: [desc: t.id],
      preload: :role,
      select_merge: %{test: fragment("left(?, 4) = 'test'", t.secret)}
    )
    |> queries.()
    |> Repo.all()
  end

  def load_api_tokens(query) do
    token_query =
      from(t in AccessToken,
        where: t.type == :api_key,
        select_merge: %{test: fragment("left(?, 4) = 'test'", t.secret)}
      )

    from(r in query, preload: [api_tokens: ^token_query])
  end

  def list_api_keys() do
    Account.list_roles(fn query ->
      query
      |> Account.filter_active_roles()
      |> Account.filter_roles_by_type(:api)
      |> Account.load_api_tokens()
      |> Account.load_role_permissions()
    end)
    |> Enum.map(fn r ->
      portals = map_portals(r)

      r.api_tokens
      |> Enum.map(fn t ->
        %{secret: t.secret, portals: portals}
      end)
    end)
    |> List.flatten()
  end

  defp map_portals(role) do
    Pub.list_portals(fn query ->
      query
      |> Pub.filter_active_portals()
      |> Pub.filter_runnable_portals(role)
    end)
    |> Enum.map(fn portal ->
      {portal.id, %{blueprint_id: portal.blueprint_id}}
    end)
    |> Map.new()
  end
end
