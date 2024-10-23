defmodule Membership.ChannelBroadcast do
  @worker_name :channel_broadcast_worker

  @typep t :: %{
           topic: String.t(),
           event: String.t(),
           payload: map
         }

  @spec push(data :: t) :: :ok
  def push(data) do
    GenServer.cast(@worker_name, data)
  end
end
