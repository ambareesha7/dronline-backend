defmodule Web.Api.AuthController do
  use Web, :controller

  action_fallback Web.FallbackController

  @decode Proto.Authentication.LoginRequest
  def login(conn, _params) do
    firebase_token = conn.assigns.protobuf.firebase_token

    with {:ok, patient} <- Authentication.login_patient(firebase_token) do
      conn |> render("login.proto", %{patient: patient})
    end
  end
end
