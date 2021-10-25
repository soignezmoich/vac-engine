defmodule VacEngineWeb.Workspace.BlueprintLive.ImportComponent do
  use VacEngineWeb, :live_component

  alias VacEngine.Processor

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok,
     socket
     |> assign(:upload_files, [])
     |> allow_upload(:json_import, accept: ~w(.json), max_entries: 1)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", _params, socket) do
    {:noreply, assign(socket, upload_files: [])}
  end

  @impl Phoenix.LiveComponent
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :json_import, ref)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("save", _params, socket) do
    can!(socket, :update, :blueprint)
    blueprint = socket.assigns.blueprint

    uploaded_files =
      consume_uploaded_entries(socket, :json_import, fn %{path: path}, _entry ->
        Processor.update_blueprint_from_file(blueprint, path)
      end)
      |> Enum.map(fn
        {:ok, br} = res ->
          send(self(), {:update_blueprint, br})
          res

        {:error, err} when is_binary(err) ->
          {:error, err}

        {:error, _} ->
          {:error, "error while processing blueprint"}
      end)

    {:noreply, update(socket, :upload_files, &(&1 ++ uploaded_files))}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"

  defp error_to_string(:not_accepted),
    do: "You have selected an unacceptable file type"
end
