defmodule Web.PanelApi.AuthControllerTest do
  use Web.ConnCase, async: true
  use Oban.Testing, repo: Postgres.Repo

  alias Proto.PanelAuthentication.ChangePasswordRequest
  alias Proto.PanelAuthentication.ConfirmPasswordChangeRequest
  alias Proto.PanelAuthentication.LoginRequest
  alias Proto.PanelAuthentication.LoginResponse
  alias Proto.PanelAuthentication.RecoverPasswordRequest
  alias Proto.PanelAuthentication.SendPasswordRecoveryRequest
  alias Proto.PanelAuthentication.SignupRequest
  alias Proto.PanelAuthentication.VerifyRequest
  alias Proto.PanelAuthentication.VerifyResponse

  alias Proto.Errors.ErrorResponse
  alias Proto.Errors.FormErrors

  describe "POST change_password" do
    setup [:proto_content, :authenticate_gp]

    test "success", %{conn: conn} do
      proto =
        %{
          password: "NewPassword1!"
        }
        |> ChangePasswordRequest.new()
        |> ChangePasswordRequest.encode()

      conn = post(conn, panel_auth_path(conn, :change_password), proto)

      assert_enqueued(worker: Mailers.MailerJobs)

      assert %{success: 1} = Oban.drain_queue(queue: :mailers)

      assert response(conn, 200)
    end
  end

  describe "POST confirm_change_password" do
    setup [:proto_content]

    test "success", %{conn: conn} do
      specialist = Authentication.Factory.insert(:specialist)

      password_change =
        Authentication.Factory.insert(:password_change, specialist_id: specialist.id)

      proto =
        %{
          confirmation_token: password_change.confirmation_token
        }
        |> ConfirmPasswordChangeRequest.new()
        |> ConfirmPasswordChangeRequest.encode()

      conn = post(conn, panel_auth_path(conn, :confirm_password_change), proto)

      assert response(conn, 200)
    end
  end

  describe "POST login" do
    setup [:proto_content]

    test "verified specialist", %{conn: conn} do
      verified_specialist =
        Authentication.Factory.insert(:verified_specialist, password: "Password1!")

      proto =
        %{
          email: verified_specialist.email,
          password: "Password1!"
        }
        |> LoginRequest.new()
        |> LoginRequest.encode()

      conn = post(conn, panel_auth_path(conn, :login), proto)

      %LoginResponse{auth_token: auth_token, active_package_type: "BASIC"} =
        proto_response(conn, 200, LoginResponse)

      {:ok, logged_in_specialist} = Authentication.authenticate_specialist(auth_token)
      assert logged_in_specialist.id == verified_specialist.id
    end

    test "unverified specialist", %{conn: conn} do
      unverified_specialist = Authentication.Factory.insert(:not_onboarded_specialist)

      proto =
        %{
          email: unverified_specialist.email,
          password: unverified_specialist.password
        }
        |> LoginRequest.new()
        |> LoginRequest.encode()

      conn = post(conn, panel_auth_path(conn, :login), proto)

      assert %ErrorResponse{
               simple_error: %{
                 message:
                   "You have not verified your email address. Please check your inbox to verify your account"
               }
             } = proto_response(conn, 422, ErrorResponse)
    end

    test "invalid credentials", %{conn: conn} do
      proto =
        %{
          email: "invalid",
          password: "invalid"
        }
        |> LoginRequest.new()
        |> LoginRequest.encode()

      conn = post(conn, panel_auth_path(conn, :login), proto)

      assert response(conn, 401)
    end
  end

  describe "POST signup" do
    setup [:proto_content]

    test "creates a GP and their team when someone registers as a hospital", %{conn: conn} do
      email = "1@example.com"

      proto =
        %{
          email: email
        }
        |> SignupRequest.new()
        |> SignupRequest.encode()

      resp = post(conn, panel_auth_path(conn, :signup) <> "?type=hospital-or-clinic", proto)

      assert resp.status == 201

      assert {:ok, %{type: "GP"} = specialist} = Authentication.Specialist.fetch_by_email(email)
      assert Teams.specialist_team_id(specialist.id)
    end

    test "creates a team for specialist when signing up as a specialist group", %{conn: conn} do
      email = "1@example.com"

      proto =
        %{
          email: email,
          password: "Password1!"
        }
        |> SignupRequest.new()
        |> SignupRequest.encode()

      resp = post(conn, panel_auth_path(conn, :signup) <> "?type=specialist-group", proto)

      assert resp.status == 201

      assert {:ok, %{type: "EXTERNAL"} = specialist} =
               Authentication.Specialist.fetch_by_email(email)

      assert Teams.specialist_team_id(specialist.id)
    end

    test "success", %{conn: conn} do
      proto =
        %{
          email: "1@example.com",
          password: "Password1!"
        }
        |> SignupRequest.new()
        |> SignupRequest.encode()

      conn = post(conn, panel_auth_path(conn, :signup), proto)

      assert {:ok, %{type: "EXTERNAL"}} =
               Authentication.Specialist.fetch_by_email("1@example.com")

      assert response(conn, 201)
    end
  end

  describe "POST send_password_recovery" do
    setup [:proto_content]

    test "success", %{conn: conn} do
      _specialist = Authentication.Factory.insert(:verified_specialist, email: "1@example.com")

      proto =
        %{
          email: "1@example.com"
        }
        |> SendPasswordRecoveryRequest.new()
        |> SendPasswordRecoveryRequest.encode()

      conn = post(conn, panel_auth_path(conn, :send_password_recovery), proto)

      assert response(conn, 200)
    end

    test "unverified specialist", %{conn: conn} do
      _specialist = Authentication.Factory.insert(:specialist, email: "1@example.com")

      proto =
        %{
          email: "1@example.com"
        }
        |> SendPasswordRecoveryRequest.new()
        |> SendPasswordRecoveryRequest.encode()

      conn = post(conn, panel_auth_path(conn, :send_password_recovery), proto)

      assert response(conn, 200)
    end
  end

  describe "POST recover_password" do
    setup [:proto_content]

    test "success", %{conn: conn} do
      specialist = Authentication.Factory.insert(:specialist_during_password_recovery)

      proto =
        %{
          password_recovery_token: specialist.password_recovery_token,
          new_password: "Password1!"
        }
        |> RecoverPasswordRequest.new()
        |> RecoverPasswordRequest.encode()

      conn = post(conn, panel_auth_path(conn, :recover_password), proto)

      assert response(conn, 200)
    end

    test "validation error", %{conn: conn} do
      specialist = Authentication.Factory.insert(:specialist_during_password_recovery)

      proto =
        %{
          password_recovery_token: specialist.password_recovery_token,
          new_password: ""
        }
        |> RecoverPasswordRequest.new()
        |> RecoverPasswordRequest.encode()

      conn = post(conn, panel_auth_path(conn, :recover_password), proto)

      %ErrorResponse{form_errors: %FormErrors{}} = proto_response(conn, 422, ErrorResponse)
    end
  end

  describe "POST verify" do
    setup [:proto_content]

    test "success", %{conn: conn} do
      specialist = Authentication.Factory.insert(:specialist)

      proto =
        %{
          verification_token: specialist.verification_token
        }
        |> VerifyRequest.new()
        |> VerifyRequest.encode()

      conn = post(conn, panel_auth_path(conn, :verify), proto)

      assert %VerifyResponse{auth_token: auth_token} = proto_response(conn, 200, VerifyResponse)
      assert is_binary(auth_token)
    end
  end
end
