defmodule SdvorLogger.JsonMsgsAdapter do
  use Mongo.Pool, name: __MODULE__, adapter: Mongo.Pool.Poolboy

  def start_link(db_name) do
    SdvorLogger.JsonMsgsAdapter.start_link(
      database: db_name,
      hostname: Application.get_env(:sdvor_logger, :mongo_hostname)
    )
  end

  def add_timestamp(msg), do: msg |> Map.put("timestamp", DateTime.utc_now |> DateTime.to_string)

  def write_log(msg) do
    Mongo.insert_one(__MODULE__, "json_messages", msg |> add_timestamp)
  end
end
