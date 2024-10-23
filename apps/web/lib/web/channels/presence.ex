defmodule Web.Presence do
  @behaviour Phoenix.Tracker

  alias Phoenix.Socket.Message

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(opts) do
    opts = Keyword.merge([name: __MODULE__], opts)
    Phoenix.Tracker.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    server = Keyword.fetch!(opts, :pubsub_server)
    {:ok, %{pubsub_server: server, node_name: Phoenix.PubSub.node_name(server)}}
  end

  def track(%Phoenix.Socket{} = socket, topic, key, meta \\ %{}) do
    Phoenix.Tracker.track(__MODULE__, socket.channel_pid, topic, key, meta)
  end

  def handle_diff(diff, state) do
    {:ok, _pid} =
      Task.Supervisor.start_child(Web.TaskSupervisor, fn ->
        for {topic, {joins, leaves}} <- diff do
          joins = group(joins)
          leaves = group(leaves)

          payload = %{
            proto: Web.Views.Presence.render_presence_diff(joins, leaves)
          }

          msg = %Message{
            topic: topic,
            event: "presence_diff",
            payload: payload
          }

          Phoenix.PubSub.direct_broadcast!(state.node_name, state.pubsub_server, topic, msg)
        end
      end)

    {:ok, state}
  end

  def list(topic) do
    __MODULE__
    |> Phoenix.Tracker.list(topic)
    |> group()
  end

  defp group(presences) do
    presences
    |> Enum.reverse()
    |> Enum.reduce(%{}, fn {key, meta}, acc ->
      Map.update(acc, key, [meta], fn metas ->
        [meta | metas]
      end)
    end)
  end
end
