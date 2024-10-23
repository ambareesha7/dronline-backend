defmodule OpenTok.Archives do
  def get(archive_id) do
    api_key = Application.get_env(:opentok, :api_key)

    middleware()
    |> Tesla.client()
    |> Tesla.get("v2/project/#{api_key}/archive/#{archive_id}")
    |> case do
      {:ok, response} ->
        {:ok, parse_response(response)}

      result ->
        _ = Sentry.Context.set_extra_context(%{result: result})
        _ = Sentry.capture_message("OpenTok.Archives.get/1 failure")

        :error
    end
  end

  defp middleware do
    [
      {Tesla.Middleware.BaseUrl, Application.get_env(:opentok, :api_url)},
      {Tesla.Middleware.Headers,
       [
         {"Accept", "application/json"},
         {"X-OPENTOK-AUTH", OpenTok.Authentication.generate_token()}
       ]},
      Tesla.Middleware.DecodeJson,
      Tesla.Middleware.Logger
    ]
  end

  defp parse_response(%{body: body, status: 200} = _response) when is_map(body) do
    %{
      created_at: ceil(body["createdAt"] / 1000),
      duration: body["duration"]
    }
  end

  defp parse_response(response) do
    _ = Sentry.Context.set_extra_context(%{response: response})
    _ = Sentry.capture_message("OpenTok.Archives.parse_response/1 failure")

    %{
      created_at: nil,
      duration: nil
    }
  end
end
