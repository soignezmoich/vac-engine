defmodule VacEngineWeb.MaintenanceLive.Index do
  use VacEngineWeb, :live_view

  import VacEngine.PipeHelpers
  alias VacEngine.Simulation

  on_mount(VacEngineWeb.LiveRole)
  on_mount({VacEngineWeb.LiveLocation, ~w(admin maintenance)a})

  @impl true
  def mount(_params, _session, socket) do
    can!(socket, :manage, :maintenance)

    socket
    |> assign(:upload_files, [])
    |> allow_upload(:json_import, accept: ~w(.json), max_entries: 1)
    |> ok()
  end

  @impl true
  def handle_params(_params, _session, socket) do
    socket
    |> pair(:noreply)
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, assign(socket, upload_files: [])}
  end

  @impl true
  def handle_event("save", _params, socket) do
    can!(socket, :manage, :maintenance)

    uploaded_files =
      consume_uploaded_entries(socket, :json_import, fn %{path: path}, _entry ->
        :ok = Simulation.import_all_cases(path)
        {:ok, path}
      end)
      |> Enum.map(fn
        {:ok, _} = res ->
          res

        {:error, _} ->
          {:error, "error while processing file"}
      end)

    {:noreply, update(socket, :upload_files, &(&1 ++ uploaded_files))}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"

  defp error_to_string(:not_accepted),
    do: "You have selected an unacceptable file type"
end
