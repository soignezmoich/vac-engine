defmodule VacEngineWeb.BlueprintLive.ImportComponent do
  @moduledoc """
  Blueprint importation component.
  """

  use VacEngineWeb, :live_component

  alias VacEngine.Processor
  alias Ecto.Changeset
  import VacEngine.PipeHelpers

  @impl true
  def mount(socket) do
    socket
    |> assign(:upload_files, [])
    |> allow_upload(:json_import, accept: ~w(.json), max_entries: 1)
    |> ok()
  end

  @impl true
  def handle_event("validate", _params, socket) do
    socket
    |> assign(upload_files: [])
    |> noreply()
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    socket
    |> cancel_upload(:json_import, ref)
    |> noreply()
  end

  @impl true
  def handle_event("do-import", _params, socket) do
    workspace = socket.assigns.workspace
    can!(socket, :write, workspace)

    uploaded_files =
      consume_uploaded_entries(socket, :json_import, fn %{path: path}, _entry ->
        Processor.update_blueprint_from_file(workspace, path)
        |> case do
          {:ok, blueprint} = res ->
            send(self(), {:open_blueprint, blueprint.id})
            res

          {:error, err} when is_binary(err) ->
            {:error, err}

          {:error, %Changeset{} = ch} ->
            {:error, VacEngine.EctoHelpers.flatten_changeset_errors(ch)}

          {:error, _} ->
            {:error, "error while processing blueprint"}
        end
        |> ok()
      end)

    socket
    |> update(:upload_files, &(&1 ++ uploaded_files))
    |> noreply()
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected a non json file"
end
