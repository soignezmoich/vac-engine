import Ecto.Query
alias VacEngine.Processor.Blueprint
alias VacEngine.Processor
alias VacEngine.Repo
alias Fixtures.Blueprints

Logger.configure(level: :error)

Blueprints.blueprints()
|> Enum.filter(fn
  {:ruleset0, _} -> true
  _ -> false
end)
|> Enum.each(fn {name, br_def} ->
  name = to_string(name)

  from(b in Blueprint, where: b.name == ^name)
  |> Repo.all()
  |> Enum.map(fn br ->
    Processor.get_blueprint!(br.id)
  end)
  |> Enum.each(fn br ->
    Processor.update_blueprint(br, br_def)
    |> case do
      {:ok, _} ->
        IO.puts("Updated blueprint #{name}")

      {:error, changeset} ->
        IO.puts("Error in blueprint #{name}")

        VacEngineWeb.ErrorHelpers.inspect_changeset(changeset)
        |> IO.puts()
    end
  end)
end)
