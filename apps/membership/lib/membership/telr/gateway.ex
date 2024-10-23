defmodule Membership.Telr.Gateway do
  use Tesla, docs: false

  plug(Tesla.Middleware.JSON)

  @spec send(map) :: {:ok, map} | {:error, String.t()} | :error
  def send(body) do
    body = assign_credentials(body)

    gateway_url = Application.get_env(:membership, :gateway_url)

    gateway_url
    |> post(body)
    |> case do
      {:ok, %Tesla.Env{status: 200, body: %{"error" => error}}} = failure ->
        send_sentry_report(failure)
        {:error, error["message"] <> " - " <> error["details"]}

      {:ok, %Tesla.Env{status: 200} = env} ->
        {:ok, env.body}

      failure ->
        send_sentry_report(failure)
        :error
    end
  end

  defp assign_credentials(body) do
    Map.merge(body, %{
      "store" => Application.get_env(:membership, :store_id),
      "authkey" => Application.get_env(:membership, :authkey)
    })
  end

  defp send_sentry_report(failure) do
    _ = Sentry.Context.set_extra_context(%{failure: failure})
    _ = Sentry.capture_message("Membership.Telr.Gateway.send/1 failure")

    :ok
  end
end
