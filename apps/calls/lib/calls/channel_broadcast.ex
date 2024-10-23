defmodule Calls.ChannelBroadcast do
  @worker_name :channel_broadcast_worker

  # "DEPRECATED"
  @typep direct_broadcast :: %{
           topic: String.t(),
           event: String.t(),
           payload: %{
             required(:proto) => struct,
             optional(atom) => term
           }
         }

  @typep push_data :: %{
           topic: String.t(),
           event: String.t(),
           payload: map
         }

  @typep action :: atom | tuple

  @spec push(data :: push_data | direct_broadcast) :: :ok
  def push(data) do
    GenServer.cast(@worker_name, data)
  end

  @spec broadcast(data :: action) :: :ok
  def broadcast(data) do
    GenServer.cast(@worker_name, data)
  end
end
