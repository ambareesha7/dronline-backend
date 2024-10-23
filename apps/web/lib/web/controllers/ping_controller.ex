defmodule Web.PingController do
  use Web, :controller

  def ping(conn, _params) do
    conn |> send_resp(200, "pong")
  end
end
