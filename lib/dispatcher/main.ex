defmodule SdvorLogger.Dispatcher.Main do
  def handle(msg) do
    spawn_link(fn() ->
      msg |> decode |> deliver
    end)
  end

  def decode(msg) do
    Poison.Parser.parse!(msg)
  end

  def deliver(msg) when is_map(msg) do
    case msg["msg_type"] do
      "regular" -> SdvorLogger.FileAdapter.Adapter.write_log(msg)
      "json" -> SdvorLogger.MongoAdapter.Adapter.write_log(msg)
      _ -> SdvorLogger.FileAdapter.Adapter.write_log(msg)
    end
    {:ok, msg}
  end

  def deliver(msg), do: SdvorLogger.FileAdapter.Adapter.write_log(msg)
end
