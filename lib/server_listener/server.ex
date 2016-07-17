defmodule SdvorLogger.ServerListener.Server do
  use Application
  use Supervisor
  require Logger

  @doc """
  Supervisor callback
  """
  def init(_) do
    Logger.info "Init supervisor..."
    children =
    [
      worker(SdvorLogger.ServerListener.Handler, [], restart: :permanent)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

  @doc """
  Entrypoint for application.

  params:
    port - number of TCP port for avaiting connections
  """
  def start(_type, _) do
    {:ok, _res } = SdvorLogger.FileAdapter.Adapter.start(
      Application.get_env(:sdvor_logger, :path_to_file),
      Application.get_env(:sdvor_logger, :filename)
    )
    # {:ok, _res } = SdvorLogger.MongoAdapter.Adapter.start(
    #   Application.get_env(:sdvor_logger, :db_name)
    # )
    # :gen_tcp socket options:
    # :binary – way of decoding package. can be a list, but binary is faster
    # packet: :raw raw – full packet, line – delimeted by line breaks
    # active: :false true – socket open for new connections and all packets will be accepted (active mode)
    #                false – socket open for new connections and after one packet of data transmission channel will be clossed (passive mode)
    #                :once - socket open for new connections and accepts only one message in active mode and then switches to passive
    {:ok, socket} = :gen_tcp.listen(
      Application.get_env(:sdvor_logger, :port),
      [:binary, packet: :raw, active: false, reuseaddr: true]
    )
    Logger.info "Ready to accept connections..."
    # activate supervision
    {:ok, sup} = Supervisor.start_link(__MODULE__, socket)
    # they will be started only when it needed so
    spawn_link(__MODULE__, :start_workers, [sup, socket, Application.get_env(:sdvor_logger, :workers_count)])
    infinite_loop
  end

  # TODO: please find a way to not use this
  def infinite_loop do
    Process.sleep(10)
    infinite_loop
  end

  @doc """
  workers starter
  """
  def start_workers(sup, socket, workers_count) do
    Logger.info "Starting workers..."
    (1..workers_count) |> Enum.each(fn(_) -> Supervisor.start_child(sup, [socket]) end)
    Logger.info "All workers ready!"
  end
end
