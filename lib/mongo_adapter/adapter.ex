defmodule SdvorLogger.MongoAdapter.Adapter do
  use Mongo.Pool,
    name: __MODULE__,
    adapter: Mongo.Pool.Poolboy
    #hostname: Application.get_env(:sdvor_logger, :mongo_hostname) # def port = 27017

  def start(db_name) do
    SdvorLogger.MongoAdapter.Adapter.start_link(
      database: db_name,
      hostname: Application.get_env(:sdvor_logger, :mongo_hostname)
    )
  end

  def write_log(msg) when is_map(msg) do
    Mongo.insert_one(__MODULE__, "queue_messages_collection", Map.put(msg, "timestamp", DateTime.utc_now |> DateTime.to_string))
  end
end
