defmodule PushNotifications.APNS.Client do
  use GenServer

  @env Mix.env()

  def send_call_notification(device_id, body) do
    GenServer.cast(__MODULE__, {:send_call_notification, device_id, body})
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, @env, name: __MODULE__)
  end

  @impl true
  def init(:prod) do
    {:ok, _conn} = connect()
  end

  @impl true
  def init(_) do
    :ignore
  end

  @impl true
  def handle_cast({:send_call_notification, device_id, body}, conn) do
    token = PushNotifications.APNS.AccessToken.get_token()

    encoded_body = Jason.encode!(body)

    request =
      Mint.HTTP2.request(
        conn,
        "POST",
        "/3/device/#{device_id}",
        [
          {"authorization", "bearer #{token}"},
          {"apns-expiration", "0"},
          {"apns-priority", "10"},
          {"apns-push-type", "voip"},
          {"apns-topic", apns_topic_url()}
        ],
        encoded_body
      )

    case request do
      {:ok, conn, _request_ref} ->
        {:noreply, conn}

      {:error, _request_ref, reason} ->
        _ = report_request_error(reason)

        {:ok, conn} = connect()

        send_call_notification(device_id, body)

        {:noreply, conn}
    end
  end

  @impl true
  def handle_info(message, conn) do
    case Mint.HTTP.stream(conn, message) do
      :unknown ->
        _ = report_unknown_message(message)

        {:noreply, conn}

      {:ok, conn, responses} ->
        _ = handle_responses(conn, responses)

        {:noreply, conn}

      {:error, conn, reason, responses} ->
        _ = report_error_response(conn, reason, responses)

        {:noreply, conn}
    end
  end

  defp connect do
    Mint.HTTP2.connect(:https, apns_url(), 443)
  end

  defp handle_responses(_conn, []), do: :ok

  defp handle_responses(conn, responses) do
    case response_status(responses) do
      200 ->
        :ok

      _ ->
        message = "PushNotifications.APNS.Client.send_notification/1 failure"

        _ =
          Sentry.capture_message(message,
            extra: %{responses: responses, conn: conn},
            result: :none
          )
    end
  end

  defp response_status(responses) do
    Enum.reduce_while(responses, nil, fn
      {:status, _ref, code}, _acc ->
        {:halt, code}

      _, acc ->
        {:cont, acc}
    end)
  end

  defp report_request_error(reason) do
    message = "PushNotifications.APNS.Client request error"

    _ =
      Sentry.capture_message(message,
        extra: %{reason: reason},
        result: :none
      )
  end

  defp report_error_response(conn, reason, responses) do
    message = "PushNotifications.APNS.Client received error"

    _ =
      Sentry.capture_message(message,
        extra: %{reason: reason, conn: conn, responses: responses},
        result: :none
      )
  end

  defp report_unknown_message(socket_message) do
    message = "PushNotifications.APNS.Client received unknown message"

    _ =
      Sentry.capture_message(message,
        extra: %{socket_message: socket_message},
        result: :none
      )
  end

  defp apns_url, do: Application.get_env(:push_notifications, :apns_url)
  defp apns_topic_url, do: Application.get_env(:push_notifications, :apns_topic_url)
end
