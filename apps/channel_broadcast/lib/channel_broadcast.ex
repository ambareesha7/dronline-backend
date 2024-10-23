defmodule ChannelBroadcast do
  @worker_name :channel_broadcast_worker

  @typep action :: atom | tuple

  @spec broadcast(data :: action) :: :ok
  def broadcast(data) do
    GenServer.cast(@worker_name, data)
  end
end
