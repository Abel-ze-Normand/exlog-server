defmodule SdvorLogger.Dispatcher.Main do
  require Logger

  def handle(msg) do
    msg |> decode |> deliver
  end

  def decode(msg) do
    msg |> inspect |> Logger.info
    Poison.Parser.parse!(msg)
  end

  def deliver(msg) when is_map(msg) do
    case msg["msg_type"] do
      "regular" -> SdvorLogger.FileAdapter.Adapter.write_log(msg)
      "json" -> msg["message"] |> Poison.Parser.parse! |> SdvorLogger.MongoAdapter.Adapter.write_log
      _ -> SdvorLogger.FileAdapter.Adapter.write_log(msg)
    end
    {:ok, msg}
  end

  def deliver(msg), do: SdvorLogger.FileAdapter.Adapter.write_log(msg)
end
