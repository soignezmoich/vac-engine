defmodule VacEngine.Query do
  import Ecto.Query

  def filter_by_query(query, search) do
    Integer.parse(search)
    |> case do
      {n, ""} ->
        from(b in query, where: b.id == ^n)

      _ ->
        search = "%#{search}%"

        from(b in query,
          where: ilike(b.name, ^search) or ilike(b.description, ^search)
        )
    end
  end

  def limit(query, limit) do
    from(b in query, limit: ^limit)
  end

  def order_by(query, key) do
    from(r in query, order_by: field(r, ^key))
  end
end
