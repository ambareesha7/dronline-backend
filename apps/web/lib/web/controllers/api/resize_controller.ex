defmodule Web.Api.ResizeController do
  use Web, :controller

  action_fallback Web.FallbackController

  import Mockery.Macro

  def resize(conn, params) do
    %{"width" => width, "height" => height, "url" => url} = params

    {:ok, status, headers, body} =
      mockable(Upload.Resizer, by: Upload.ResizerMock).resize(url, width, height)

    conn
    |> Plug.Conn.merge_resp_headers(headers)
    |> resp(status, body)
  end
end
