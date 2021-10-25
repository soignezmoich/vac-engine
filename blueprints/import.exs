# alias VacEngine.Processor.Blueprint
# alias VacEngine.Processor
# alias VacEngine.Repo
# alias Fixtures.Blueprints
#
# Logger.configure(level: :error)
#
# Blueprints.blueprints()
# |> Enum.filter(fn
#   {:ruleset0, _} -> true
#   _ -> false
# end)
# |> Enum.each(fn {name, br_def} ->
#   name = to_string(name)
#
#   from(b in Blueprint, where: b.name == ^name)
#   |> Repo.all()
#   |> Enum.map(fn br ->
#     Processor.get_blueprint!(br.id)
#   end)
#   |> Enum.each(fn br ->
#     Processor.update_blueprint(br, br_def)
#     |> case do
#       {:ok, _} ->
#         IO.puts("Updated blueprint #{name}")
#
#       {:error, changeset} ->
#         IO.puts("Error in blueprint #{name}")
#
#         VacEngineWeb.ErrorHelpers.inspect_changeset(changeset)
#         |> IO.puts()
#     end
#   end)
# end)
#

import Ecto.Query
alias VacEngine.Account
alias VacEngine.Processor.Blueprint
alias VacEngine.Processor
alias VacEngine.Repo
import VacEngine.TupleHelpers

defmodule Importer do
  @wname "Import workspace"

  defp err(msg) do
    IO.puts("/!\\\t#{msg}")
  end

  defp info(msg) do
    IO.puts("\t- #{msg}")
  end

  defp stringify_keys(map) when is_map(map) do
    map
    |> Enum.map(fn {key, val} ->
      {key, stringify_keys(val)}
    end)
    |> Map.new()
  end

  defp stringify_keys(list) when is_list(list) do
    list
    |> Enum.map(&stringify_keys/1)
  end

  defp stringify_keys(v) when is_boolean(v), do: v
  defp stringify_keys(v) when is_nil(v), do: v
  defp stringify_keys(v) when is_atom(v), do: to_string(v)
  defp stringify_keys(v), do: v

  def inspect_changeset(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn changeset, field, msg ->
      s =
        "#{changeset.data.__struct__}"
        |> String.split(".")
        |> List.last()

      name = Ecto.Changeset.get_field(changeset, :name)
      msg = VacEngineWeb.ErrorHelpers.translate_error(msg)

      s =
        [s, name, field]
        |> VacEngine.MapHelpers.compact()
        |> Enum.join(".")

      "#{s}: #{msg}"
    end)
    |> flatten_all
    |> Enum.join("\n")
  end

  defp flatten_all(map) when is_map(map) do
    map
    |> Map.values()
    |> Enum.map(&flatten_all/1)
    |> List.flatten()
  end

  defp flatten_all(list) when is_list(list) do
    list
    |> Enum.map(&flatten_all/1)
    |> List.flatten()
  end

  defp flatten_all(v), do: v

  def get_or_create_workspace() do
    Account.list_workspaces()
    |> Enum.find(fn w ->
      w.name == @wname
    end)
    |> case do
      nil ->
        Account.create_workspace(%{name: @wname})
        |> then(fn {:ok, w} -> w end)

      w ->
        w
    end
  end

  def load_blueprint(path) do
    name = Path.basename(path, ".exs")
    info("Name: #{name}")

    Code.eval_file(path)
    |> then(fn {br, _} -> br end)
    |> stringify_keys()
    |> then(fn br ->
      info("Loaded definition from #{path}")
      {:ok, %{path: path, attrs: br, name: name}}
    end)
  rescue
    err ->
      err("Cannot parse file.")
      IO.puts("#{Exception.message(err)}")
      {:error, %{path: path}}
  end

  def get_blueprint({:ok, %{name: name} = state}) do
    workspace = get_or_create_workspace()

    from(b in Blueprint,
      where: b.name == ^name and b.workspace_id == ^workspace.id,
      select: b.id
    )
    |> Repo.all()
    |> case do
      [] ->
        Processor.create_blueprint(workspace, %{name: name})

      [id|_] ->
        Processor.fetch_blueprint(workspace, id)
    end
    |> case do
      {:ok, br} ->
        info("Fetched blueprint")

        state
        |> Map.put(:blueprint, br)
        |> ok()

      _res ->
        {:error, state}
    end
  end

  def get_blueprint(res), do: res

  def update_blueprint(
        {:ok, %{blueprint: br, attrs: attrs} = state}
      ) do
    Processor.update_blueprint(br, attrs)
    |> case do
      {:ok, br} ->
        info("Updated blueprint")

        state
        |> Map.put(:blueprint, br)
        |> ok()

      {:error, changeset} ->
        err("Error in definition")

        inspect_changeset(changeset)
        |> IO.puts()

        {:error, state}
    end
  end

  def update_blueprint(res), do: res

  def serialize_blueprint({:ok, %{blueprint: blueprint, name: name} = state}) do
    name = "#{name} at #{Timex.format!(NaiveDateTime.utc_now(), "{ISOdate} {h24}:{m}:{s}")}"
    Processor.serialize_blueprint(blueprint)
    |> Map.put(:name, name)
    |> Jason.encode()
    |> case do
      {:ok, json} ->
        info("Serialized blueprint")

        state
        |> Map.put(:json, json)
        |> ok()

      {:error, state} ->
        err("Cannot serialize blueprint")

        {:error, state}
    end
  end

  def serialize_blueprint(res), do: res

  def export_blueprint({:ok, %{json: json, name: name} = state}) do
    dstdir = Path.join(__DIR__, "json/")
    dstpath = Path.join(__DIR__, "json/#{name}.json")

    with :ok <- File.mkdir_p(dstdir),
         :ok <- File.write(dstpath, json) do
      info("Wrote json to #{dstpath}")
      {:ok, state}
    else
      _ ->
        err("Cannot write json")

        {:error, state}
    end
  end

  def export_blueprint(res), do: res

  def log_start(path) do
    IO.puts("\n\n")
    IO.puts("## START Processing #{path}")
    path
  end

  def log_end({:error, %{path: path}}) do
    err("ERROR processing #{path}")
  end

  def log_end({:ok, %{path: path}}) do
    IO.puts("## DONE processing #{path}")
  end

  def process_path(path) do
    path
    |> log_start()
    |> load_blueprint()
    |> get_blueprint()
    |> update_blueprint()
    |> serialize_blueprint()
    |> export_blueprint()
    |> log_end()
  end

  def import_blueprints() do
    Logger.configure(level: :error)

    Path.join(__DIR__, "src/*.exs")
    |> Path.wildcard()
    |> Enum.each(&process_path/1)
  end
end

Importer.import_blueprints()
