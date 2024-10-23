defmodule Web.Api.ChannelsTokenController do
  use Web, :controller

  def show(conn, _params) do
    id = conn.assigns.current_patient_id
    salt = Application.get_env(:web, :channels_token_salt)
    token = Phoenix.Token.sign(conn, salt, %{id: id, type: :PATIENT})

    conn |> render("show.proto", %{token: token})
  end
end
