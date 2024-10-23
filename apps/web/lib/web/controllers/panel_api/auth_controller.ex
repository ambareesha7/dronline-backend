defmodule Web.PanelApi.AuthController do
  use Web, :controller

  action_fallback(Web.FallbackController)

  @decode Proto.PanelAuthentication.ChangePasswordRequest
  def change_password(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id
    password = conn.assigns.protobuf.password

    with {:ok, _job} <-
           Authentication.create_password_change(specialist_id, password) do
      send_resp(conn, 200, "")
    end
  end

  @decode Proto.PanelAuthentication.ConfirmPasswordChangeRequest
  def confirm_password_change(conn, _params) do
    confirmation_token = conn.assigns.protobuf.confirmation_token

    with :ok <- Authentication.confirm_password_change(confirmation_token) do
      conn |> send_resp(200, "")
    end
  end

  @decode Proto.PanelAuthentication.LoginRequest
  def login(conn, _params) do
    email = conn.assigns.protobuf.email
    password = conn.assigns.protobuf.password

    with {:ok, specialist} <- Authentication.login_specialist(email, password) do
      conn |> render("login.proto", %{specialist: specialist})
    end
  end

  @decode Proto.PanelAuthentication.SignupRequest
  def signup(conn, %{"type" => "hospital-or-clinic"}) do
    email = conn.assigns.protobuf.email

    with {:ok, _account} <- Admin.create_internal_specialist(%{email: email, type: 1}),
         {:ok, specialist} <- Authentication.Specialist.fetch_by_email(email),
         {:ok, _team} <- Teams.create_team(specialist.id, %{}) do
      send_resp(conn, 201, "")
    end
  end

  def signup(conn, %{"type" => "specialist-group"}) do
    %{email: email, password: password} = conn.assigns.protobuf

    with :ok <- Authentication.signup_external(email, password),
         {:ok, specialist} <- Authentication.Specialist.fetch_by_email(email),
         {:ok, _team} <- Teams.create_team(specialist.id, %{}) do
      conn |> send_resp(201, "")
    end
  end

  def signup(conn, _params) do
    %{email: email, password: password} = conn.assigns.protobuf

    with :ok <- Authentication.signup_external(email, password) do
      conn |> send_resp(201, "")
    end
  end

  @decode Proto.PanelAuthentication.SendPasswordRecoveryRequest
  def send_password_recovery(conn, _params) do
    email = conn.assigns.protobuf.email

    with :ok <- Authentication.send_specialist_password_recovery(email) do
      conn |> send_resp(200, "")
    end
  end

  @decode Proto.PanelAuthentication.RecoverPasswordRequest
  def recover_password(conn, _params) do
    %{password_recovery_token: token, new_password: new_password} = conn.assigns.protobuf

    with :ok <- Authentication.recover_specialist_password(token, new_password) do
      conn |> send_resp(200, "")
    end
  end

  @decode Proto.PanelAuthentication.VerifyRequest
  def verify(conn, _params) do
    verification_token = conn.assigns.protobuf.verification_token

    with {:ok, specialist} <- Authentication.verify_specialist(verification_token) do
      conn |> render("verify.proto", %{specialist: specialist})
    end
  end
end
