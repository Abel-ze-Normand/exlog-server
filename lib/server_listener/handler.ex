defmodule SdvorLogger.ServerListener.Handler do
  require Logger

  @doc """
  Entry point for started child
  """
  def start_link(socket) do
    Logger.info "Worker started!"
    #next_connection(socket)
    connection(socket)
  end

  def connection(socket) do
    {:ok, msg} = :czmq.zstr_recv(socket)
    msg |> SdvorLogger.Dispatcher.Main.handle
    connection(socket)
  end

  ### OLD ###

  @doc """
  Awaits for new connection and serves messages
  """
  def next_connection(socket) do
    #{:ok, client} = :gen_tcp.accept(socket)
    Logger.info "New connection"
    spawn(__MODULE__, :next_connection, [socket])
    handle_connection(client)
  end

  def handle_connection(client_socket) do
    client_socket |> fetch_data |> SdvorLogger.Dispatcher.Main.handle
    handle_connection(client_socket)
  end

  defp fetch_data(socket) do
    :inet.setopts(socket, active: :once)
    receive do
      {:tcp, _, msg } ->
        msg
      _ ->
        "{\"state\": \"TRANSMISSION CLOSED\"}"
    end
  end
end
