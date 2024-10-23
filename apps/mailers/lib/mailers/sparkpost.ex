defmodule Mailers.Sparkpost do
  def send(body) do
    case Tesla.post(client(), "/transmissions", body) do
      {:ok, %Tesla.Env{body: %{"results" => %{"total_rejected_recipients" => 0}}}} ->
        :ok

      response ->
        _ =
          Sentry.Context.set_extra_context(%{
            body: body,
            response: response
          })

        :error
    end
  end

  def client do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, "https://api.sparkpost.com/api/v1"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers,
       [
         {"Authorization", Application.get_env(:mailers, :sparkpost_api_key, "")}
       ]}
    ])
  end
end
