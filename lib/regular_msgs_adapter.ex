defmodule SdvorLogger.RegularMsgsAdapter do
  def start_link(db_name) do
    SdvorLogger.RegularMsgsAdapter.start_link(
      database: db_name,
      hostname: Application.get_env(:sdvor_logger, :mongo_hostname)
    )
  end

  def add_timestamp(msg), do: msg |> Map.put("timestamp", DateTime.utc_now |> DateTime.to_string)

  def write_log(msg) do
    Mongo.insert_one(__MODULE__, msg["msg_type"], msg |> add_timestamp)
  end
end
