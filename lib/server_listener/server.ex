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

    ### ADAPTERS INITIALIZATION ###
    {:ok, _res } = SdvorLogger.FileAdapter.Adapter.start_link(
      Application.get_env(:sdvor_logger, :path_to_file),
      Application.get_env(:sdvor_logger, :filename)
    )
    {:ok, _res } = SdvorLogger.MongoAdapter.Adapter.start_link(
      Application.get_env(:sdvor_logger, :db_name)
    )
    ### END OF ADAPTERS INITIALIZATION ###

    {:ok, socket} = :erlangzmq.socket(:rep)
    {:ok, _pid} = :erlangzmq.bind(socket, :tcp, '0.0.0.0', Application.get_env(:sdvor_logger, :port))

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
  Workers starter
  """
  def start_workers(sup, socket, workers_count) do
    Logger.info "Starting workers..."
    (1..workers_count) |> Enum.each(fn(_) -> Supervisor.start_child(sup, [socket]) end)
    Logger.info "All workers ready!"
  end
end
