defmodule Web.Plugs.AuthenticateAdmin do
  use Web, :plug

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _opts) do
    token = conn |> get_req_header("x-auth-token") |> List.first()

    case token && Authentication.authenticate_admin(token) do
      {:ok, admin_data} ->
        conn
        |> assign(:current_admin_id, admin_data.id)
        |> assign(:scopes, ["ADMIN"])

      _ ->
        conn
        |> send_resp(401, "")
        |> halt()
    end
  end
end
