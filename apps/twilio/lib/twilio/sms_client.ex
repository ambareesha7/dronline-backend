defmodule Twilio.SMSClient do
  use Tesla, docs: false

  plug(
    Tesla.Middleware.BaseUrl,
    "https://api.twilio.com/2010-04-01/Accounts/" <> Application.get_env(:twilio, :account_sid)
  )

  plug(Tesla.Middleware.BasicAuth,
    username: Application.get_env(:twilio, :key_sid),
    password: Application.get_env(:twilio, :key_secret)
  )

  plug(Tesla.Middleware.FormUrlencoded)
  plug(Tesla.Middleware.DecodeJson)
  plug(Tesla.Middleware.Logger)

  def send(phone_number, body) do
    resp =
      post("/Messages.json", %{
        MessagingServiceSid: message_service_sid(),
        To: phone_number,
        Body: body
      })

    case resp do
      {:ok, %{status: 201}} ->
        :ok

      result ->
        Sentry.Context.set_extra_context(%{result: result})
        _ = Sentry.capture_message("Twilio.SMSClient.send/1 invalid result")

        {:error, result}
    end
  end

  defp message_service_sid, do: Application.get_env(:twilio, :messege_service_sid)
end
