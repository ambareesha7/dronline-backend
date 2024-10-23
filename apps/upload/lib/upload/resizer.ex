defmodule Upload.Resizer do
  @moduledoc """
  Module is responsible for resizing given images with requests to thumbor
  server.
  """

  defp middleware do
    [
      {Tesla.Middleware.BaseUrl, Application.get_env(:upload, :thumbor_url)},
      Tesla.Middleware.Logger
    ]
  end

  defp client do
    Tesla.client(middleware())
  end

  @doc """
  Fires request to thumbor with given params - url, width and height

  Returns {:ok, status, headers, body} with data from response
  * Headers are returned without `server` header
  """
  def resize(url, width, height) do
    url = URI.encode(url)
    resp = Tesla.get(client(), "unsafe/#{width}x#{height}/#{url}")

    case resp do
      {:ok, response} ->
        # Don't show that there is server behind Cowboy
        headers = List.keydelete(response.headers, "server", 0)

        {:ok, response.status, headers, response.body}

      result ->
        extra = %{result: result}
        Sentry.Context.set_extra_context(extra)

        raise "Upload.Resizer.resize/3 invalid result"
    end
  end
end
