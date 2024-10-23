defmodule Web.Api.ChannelsTokenControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Channels.GetTokenResponse

  setup [:authenticate_patient]

  test "GET show", %{conn: conn, current_patient: current_patient} do
    conn = get(conn, channels_token_path(conn, :show))

    %GetTokenResponse{token: token} = proto_response(conn, 200, GetTokenResponse)

    current_patient_id = current_patient.id
    salt = Application.get_env(:web, :channels_token_salt)

    {:ok, %{type: :PATIENT, id: ^current_patient_id}} =
      Phoenix.Token.verify(conn, salt, token, max_age: :infinity)
  end
end
