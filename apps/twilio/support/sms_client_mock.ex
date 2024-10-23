defmodule Twilio.SMSClientMock do
  def send(_phone_number, _body) do
    :ok
  end
end
