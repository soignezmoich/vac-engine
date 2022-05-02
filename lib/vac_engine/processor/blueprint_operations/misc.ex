defmodule VacEngine.Processor.Blueprints.Misc do
  @moduledoc false

  import Ecto.Query
  import VacEngine.PipeHelpers
  import VacEngine.EctoHelpers

  alias Ecto.Multi
  alias VacEngine.Repo
  alias VacEngine.Processor.Blueprint
  alias VacEngine.Processor.Blueprints.Load
  alias VacEngine.Processor.Blueprints.Save
  alias VacEngine.Pub.Publication

  def duplicate_blueprint(blueprint) do
    Multi.new()
    |> Multi.run(:blueprint, fn _repo, _ ->
      Load.get_blueprint(blueprint.id, fn query ->
        query
        |> Load.load_blueprint_workspace()
        |> Load.load_blueprint_variables()
        |> Load.load_blueprint_full_deductions()
        |> Load.load_blueprint_simulation()
      end)
      |> case do
        nil -> {:error, "blueprint not found for duplication"}
        br -> {:ok, br}
      end
    end)
    |> Multi.run(:serialized, fn _repo, %{blueprint: br} ->
      br
      |> Load.serialize_blueprint()
      |> ok()
    end)
    |> Multi.run(:create, fn _repo,
                             %{
                               blueprint: %Blueprint{workspace: workspace},
                               serialized: serialized_blueprint
                             } ->
      Save.create_blueprint(workspace, serialized_blueprint)
    end)
    |> Multi.run(:update, fn _repo,
                             %{create: br, blueprint: %Blueprint{name: name}} ->
      Save.update_blueprint(br, %{
        "name" => make_copy_name(name)
      })
    end)
    |> transaction(:update)
  end

  def blueprint_readonly?(%Blueprint{publications: []}), do: false

  def blueprint_readonly?(%Blueprint{publications: publications})
      when is_list(publications),
      do: true

  def blueprint_readonly?(blueprint) do
    from(p in Publication,
      where: p.blueprint_id == ^blueprint.id,
      limit: 1
    )
    |> Repo.exists?()
  end

  defp make_copy_name(original_name) do
    name_root = Regex.replace(~r/ copy-\d*$/, original_name, "")

    copy_number =
      case Regex.run(~r/ copy-(\d*)$/, original_name) do
        nil -> nil
        [_full_capture, first_block] -> first_block
      end

    copy_tag =
      case copy_number do
        nil -> " copy-1"
        number -> " copy-#{String.to_integer(number) + 1}"
      end

    "#{name_root}#{copy_tag}"
  end
end
