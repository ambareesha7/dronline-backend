defmodule Twilio.NTSClientMock do
  def get_info do
    {:ok,
     %{
       username: "username",
       password: "password",
       turn_url: "turn_url",
       stun_url: "stun_url"
     }}
  end
end
