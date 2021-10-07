defmodule VacEngine.Account.AccessTokens do
  import Ecto.Query
  alias VacEngine.Repo
  alias VacEngine.Account.AccessToken
  alias VacEngine.Account.Role

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

  def create_api_token(%Role{} = role) do
    secret = generate_composite_secret(:api, role.id)

    %AccessToken{role_id: role.id, type: :api_key, secret: secret}
    |> AccessToken.changeset()
    |> Repo.insert()
  end

  def list_api_tokens(%Role{} = role) do
    from(t in AccessToken, where: t.type == :api_key and t.role_id == ^role.id)
    |> Repo.all()
  end
end