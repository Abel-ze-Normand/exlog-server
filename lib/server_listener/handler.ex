defmodule SdvorLogger.ServerListener.Handler do
  require Logger

  @doc """
  Entry point for started child
  """
  def start_link(socket) do
    Logger.info "Worker #{inspect self} started!"
    next_connection(socket)
  end

  def next_connection(socket) do
    {:ok, msg} = :erlangzmq.recv(socket)
    :erlangzmq.send(socket, <<"ok">>)
    handle(msg)
    next_connection(socket)
  end

  defp handle(msg) do
    {:ok, _pid} = spawn_link(SdvorLogger.Dispatcher, :handle, [msg])
  end
end
