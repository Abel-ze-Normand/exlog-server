defmodule SdvorLogger.Dispatcher.Main do
  def handle(msg) do
    msg |> decode |> deliver
  end

  def decode(msg) do
    Poison.Parser.parse!(msg)
  end

  def deliver(%{"msg_type": "regular"} = msg) do
    SdvorLogger.FileAdapter.Adapter.write_log(msg)
  end
  def deliver(%{"msg_type": "json"} = msg) do
    SdvorLogger.MongoAdapter.Adapter.write_log(msg)
  end
  def deliver(msg), do: SdvorLogger.FileAdapter.Adapter.write_log(msg)
end
