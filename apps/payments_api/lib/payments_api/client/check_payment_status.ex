defmodule PaymentsApi.Client.CheckPaymentStatus do
  use Tesla, docs: true

  plug(Tesla.Middleware.JSON)

  @spec send(map) :: {:ok, map} | {:error, String.t()} | :error
  def send(body) do
    body = assign_credentials(body)

    gateway_url = "#{telr_config()[:hosted_payment_api_url]}"

    middleware()
    |> Tesla.client()
    |> post(gateway_url, body)
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

  def prepare_check_request_body(ref) do
    %{
      "method" => "check",
      "order" => %{
        "ref" => ref
      }
    }
  end

  defp assign_credentials(body) do
    config = telr_config()

    Map.merge(body, %{
      "store" => "#{config[:store_id]}" |> String.to_integer(),
      "authkey" => "#{config[:payment_authkey]}"
    })
  end

  defp send_sentry_report(failure) do
    _ = Sentry.Context.set_extra_context(%{failure: failure})
    _ = Sentry.capture_message("PaymentsApi.Client.CheckPaymentStatus.send/1 failure")

    :ok
  end

  defp middleware do
    [
      Tesla.Middleware.Logger,
      {Tesla.Middleware.Headers,
       [
         {"Content-Type", "application/json"},
         {"accept", "application/json"}
       ]},
      Tesla.Middleware.Logger,
      Tesla.Middleware.JSON
    ]
  end

  defp telr_config, do: Application.get_env(:visits, :telr)
end
