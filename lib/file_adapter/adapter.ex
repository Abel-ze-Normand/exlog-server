defmodule SdvorLogger.FileAdapter.Adapter do
  use GenServer
  require Logger

  @doc """
  Entrypoint for application
  """
  def start_link(path_to_file, filename) do
    File.mkdir_p path_to_file
    {:ok, file_pid} = File.open(
      "#{path_to_file}/#{DateTime.utc_now |> DateTime.to_string}-#{filename}",
      [:append, :delayed_write]
    )
    Logger.info "File to write opened"
    GenServer.start_link(__MODULE__, file_pid, name: :file_adapter)
  end

  @doc """
  Sends message to write one to file
  """
  def write_log(msg) do
    GenServer.cast(:file_adapter, {:write, msg})
  end

  ### GENSERVER CALLBACKS ###

  def handle_cast({:write, msg}, file_pid) when is_map(msg) do
    line = Poison.encode!(msg)
    IO.binwrite(file_pid, line <> "\n")
    {:noreply, file_pid}
  end

  def handle_cast({:write, msg}, file_pid) do
    IO.binwrite(file_pid, msg <> "\n")
    {:noreply, file_pid}
  end

  def terminate(_reason, pid) do
    File.close(pid)
  end
end
