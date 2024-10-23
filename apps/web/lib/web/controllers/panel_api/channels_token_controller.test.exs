defmodule Web.PanelApi.ChannelsTokenControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Channels.GetTokenResponse

  setup [:authenticate_gp]

  test "GET show", %{conn: conn, current_gp: current_gp} do
    conn = get(conn, panel_channels_token_path(conn, :show))

    %GetTokenResponse{token: token} = proto_response(conn, 200, GetTokenResponse)

    current_gp_id = current_gp.id
    salt = Application.get_env(:web, :channels_token_salt)

    {:ok, %{type: :GP, id: ^current_gp_id}} =
      Phoenix.Token.verify(conn, salt, token, max_age: :infinity)
  end
end
