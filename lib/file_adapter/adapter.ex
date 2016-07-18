defmodule SdvorLogger.FileAdapter.Adapter do
  use GenServer
  require Logger


  @doc """
  Entrypoint for application
  """
  def start(path_to_file, filename) do
    {:ok, pid} = File.open "#{path_to_file}/#{filename}", [:append, :delayed_write]
    Logger.info "File to write opened"
    GenServer.start_link(__MODULE__, pid, name: :file_adapter)
  end

  @doc """
  Sends message to write one to file
  """
  def write_log(msg) do
    GenServer.cast(:file_adapter, {:write, msg})
  end

  ### GENSERVER CALLBACKS ###

  def handle_cast({:write, msg}, pid) when is_map(msg) do
    line = Poison.encode!(msg)
    IO.binwrite(pid, line <> "\n")
    {:noreply, pid}
  end

  def handle_cast({:write, msg}, pid) do
    IO.binwrite(pid, msg <> "\n")
    {:noreply, pid}
  end

  def terminate(_reason, pid) do
    File.close(pid)
  end
end
