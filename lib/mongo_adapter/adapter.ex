defmodule SdvorLogger.MongoAdapter.Adapter do
  use Mongo.Pool,
    name: __MODULE__,
    adapter: Mongo.Pool.Poolboy
    #hostname: Application.get_env(:sdvor_logger, :mongo_hostname) # def port = 27017

  def start_link(db_name) do
    SdvorLogger.MongoAdapter.Adapter.start_link(
      database: db_name,
      hostname: Application.get_env(:sdvor_logger, :mongo_hostname)
    )
  end

  def write_log(msg) when is_map(msg) do
    Mongo.insert_one(__MODULE__, "queue_messages_collection", msg |> Map.put("timestamp", DateTime.utc_now |> DateTime.to_string))
  end

  def write_log(msg) do
    record = %{"message" => to_string(msg)}
    Mongo.insert_one(__MODULE__, "unhandled_messages_collection", record)
  end
end
