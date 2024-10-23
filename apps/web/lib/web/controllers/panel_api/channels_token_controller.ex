defmodule Web.PanelApi.ChannelsTokenController do
  use Web, :controller

  def show(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id
    [type, _package_type] = conn.assigns.scopes

    salt = Application.get_env(:web, :channels_token_salt)

    token =
      Phoenix.Token.sign(conn, salt, %{id: specialist_id, type: String.to_existing_atom(type)})

    conn
    |> put_view(Web.Api.ChannelsTokenView)
    |> render("show.proto", %{token: token})
  end
end
