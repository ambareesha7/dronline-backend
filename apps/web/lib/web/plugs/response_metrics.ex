defmodule Web.Plugs.ResponseMetrics do
  use Web, :plug

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _opts) do
    req_start_time = :os.timestamp()

    register_before_send(conn, fn conn ->
      _metric_name = get_metric_name(conn)

      req_end_time = :os.timestamp()
      _duration = :timer.now_diff(req_end_time, req_start_time) / 1000

      conn
    end)
  end

  defp get_metric_name(conn) do
    _controller = conn.private[:phoenix_controller]
    _action = conn.private[:phoenix_action]
    _format = conn.private[:phoenix_format]
  end
end
