defmodule SdvorLogger.ServerListener.Handler do
  require Logger

  @doc """
  Entry point for started child
  """
  def start_link(socket) do
    Logger.info "Worker started!"
    next_connection(socket)
  end

  def next_connection(socket) do
    {:ok, msg} = :erlangzmq.recv(socket)
    :erlangzmq.send(socket, <<"ok">>)
    handle(msg)
    next_connection(socket)
  end

  defp handle(msg) do
    res = spawn_link(SdvorLogger.Dispatcher.Main, :handle, [msg])
    case res do
      {:ok, _pid} ->
        :ok
      _ ->
        handle(msg)
    end
  end
end
