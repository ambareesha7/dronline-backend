defmodule Web.AdminApi.AuthController do
  use Web, :controller

  action_fallback Web.FallbackController

  @decode Proto.AdminAuthentication.LoginRequest
  def login(conn, _params) do
    email = conn.assigns.protobuf.email
    password = conn.assigns.protobuf.password

    with {:ok, admin} <- Authentication.login_admin(email, password) do
      conn |> render("login.proto", %{admin: admin})
    end
  end
end
