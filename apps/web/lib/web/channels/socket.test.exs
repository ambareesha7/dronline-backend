defmodule Web.SocketTest do
  use Web.ChannelCase, async: true

  alias Web.Socket

  describe "connect/2" do
    test "with valid patient token" do
      salt = Application.get_env(:web, :channels_token_salt)
      token = Phoenix.Token.sign(Web.Endpoint, salt, %{id: 0, type: :PATIENT})

      {:ok, socket} = connect(Socket, %{"token" => token, "device_id" => "foo"})
      assert socket.assigns.current_patient_id == 0
      assert socket.assigns.type == :PATIENT
      assert socket.assigns.device_id == "foo"
    end

    test "with valid specialist token" do
      salt = Application.get_env(:web, :channels_token_salt)
      token = Phoenix.Token.sign(Web.Endpoint, salt, %{id: 0, type: :GP})

      {:ok, socket} = connect(Socket, %{"token" => token})
      assert socket.assigns.current_specialist_id == 0
      assert socket.assigns.type == :GP
    end

    test "with invalid token" do
      :error = connect(Socket, %{"token" => "invalid"})
    end

    test "without token" do
      :error = connect(Socket, %{})
    end
  end
end
