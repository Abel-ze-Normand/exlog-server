defmodule SdvorLogger.ServerListener.Server do
  use Application
  use Supervisor
  require Logger

  @doc """
  Workers supervisor callback
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
  """
  def start(_type, _) do
    ## INIT ALL ##
    with {:ok, _rma_pid} <- SdvorLogger.RegularMsgsAdapter.start_link(Application.get_env(:sdvor_logger, :db_name)),
         {:ok, _jma_pid} <- SdvorLogger.JsonMsgsAdapter.start_link(Application.get_env(:sdvor_logger, :db_name)),
         {:ok, socket}   <- :erlangzmq.socket(:rep),
         {:ok, _pid}     <- :erlangzmq.bind(socket, :tcp, '0.0.0.0', Application.get_env(:sdvor_logger, :port)),
                            Logger.info("Ready to accept connections..."),
         # activate supervision
         {:ok, sup}      <- Supervisor.start_link(__MODULE__, socket),
         _workers_pid    <- spawn_link(__MODULE__, :start_workers, [sup, socket, Application.get_env(:sdvor_logger, :workers_count)]) do
      :ok
    else
      _ -> exit(1)
    end

    infinite_loop
  end

  # TODO: please find a way to not use this
  def infinite_loop do
    Process.sleep(50)
    infinite_loop
  end

  @doc """
  Workers starter. All workers will started as soon, as it needed
  """
  def start_workers(sup, socket, workers_count) do
    Logger.info "Starting workers..."
    (1..workers_count) |> Enum.each(fn(_) -> Supervisor.start_child(sup, [socket]) end)
    Logger.info "All workers warmed up!"
  end
end
