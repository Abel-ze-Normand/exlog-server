defmodule SdvorLogger.Dispatcher do
  require Logger

  @defined_types ["regular", "json"]

  def handle(msg) do
    msg |> decode |> deliver
  end

  def decode(msg) do
    msg |> inspect |> Logger.info
    Poison.Parser.parse!(msg)
  end

  def msg_type(msg) do
    msg |> Map.get("msg_type", :no_type)
  end

  def warn_msg(msg, warn_str), do: msg |> Map.put("warning", warn_str)
  def attach_type_to_msg(msg, type), do: msg |> Map.put("type", type)

  def regular_type_msg?(msg) do
    msg_type(msg) == "regular"
  end
  def json_type_msg?(msg) do
    msg_type(msg) == "json"
  end
  def other_type_msg?(msg) do
    msg_type(msg) in @defined_types
  end
  def no_type_msg?(msg) do
    msg_type(msg) == :no_type
  end

  def deliver(msg) when is_map(msg) do
    cond do
      regular_type_msg?(msg) -> SdvorLogger.RegularMsgsAdapter.write_log(msg)
      json_type_msg?(msg)    ->
        msg |> Map.get("message") |> Poison.Parser.parse! |> SdvorLogger.JsonMsgsAdapter.write_log
      other_type_msg?(msg)   ->
        msg
        |> warn_msg("unregistered type of message, please register one or use one of predefined: #{inspect @defined_types}")
        |> SdvorLogger.RegularMsgsAdapter.write_log
      no_type_msg?(msg)      ->
        msg
        |> warn_msg("add type please to correct dispatch! available: #{inspect @defined_types}. attached 'unknown' type")
        |> attach_type_to_msg("unknown")
        |> SdvorLogger.RegularMsgsAdapter.write_log
    end
  end

  def deliver(msg) do
    %{"message" => msg, "critical" => "not JSON! Manually serialized"} |> deliver
  end
end
