defmodule Calls.TestChannelBroadcast do
  def push(message) do
    Calls.ChannelBroadcast.push(message)

    test_pid = Process.whereis(:test_process)

    if test_pid do
      send(test_pid, {:broadcast, message})
    end
  end
end
