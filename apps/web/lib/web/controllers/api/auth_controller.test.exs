defmodule Web.Api.AuthControllerTest do
  use Web.ConnCase, async: true
  use Mockery

  alias Proto.Authentication.LoginRequest
  alias Proto.Authentication.LoginResponse

  describe "POST login" do
    setup [:proto_content]

    test "returns auth_token when patient exists", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      {:ok, auth_token_entry} = Authentication.Patient.AuthTokenEntry.create(patient.id)

      {:ok, account} =
        Authentication.Patient.Account.create(%{
          firebase_id: "firebase_id",
          main_patient_id: patient.id,
          phone_number: "+48661848585"
        })

      firebase_token = Firebase.TestHelper.firebase_auth_token("3000-01-01", account.firebase_id)

      proto =
        %{
          firebase_token: firebase_token
        }
        |> LoginRequest.new()
        |> LoginRequest.encode()

      conn = post(conn, auth_path(conn, :login), proto)

      assert %LoginResponse{auth_token: auth_token} = proto_response(conn, 200, LoginResponse)
      assert auth_token == auth_token_entry.auth_token
    end

    test "creates account and returns auth_token for new_patient", %{conn: conn} do
      firebase_token = Firebase.TestHelper.firebase_auth_token("3000-01-01", "new patient")

      proto =
        %{
          firebase_token: firebase_token
        }
        |> LoginRequest.new()
        |> LoginRequest.encode()

      conn = post(conn, auth_path(conn, :login), proto)

      assert %LoginResponse{auth_token: auth_token} = proto_response(conn, 200, LoginResponse)

      {:ok, patient_id} =
        Authentication.Patient.AuthTokenEntry.fetch_patient_id_by_auth_token(auth_token)

      {:ok, account} =
        Postgres.Repo.fetch_by(Authentication.Patient.Account, main_patient_id: patient_id)

      assert account.firebase_id == "new patient"
    end

    test "invalid firebase token", %{conn: conn} do
      proto =
        %{
          firebase_token: "invalid"
        }
        |> LoginRequest.new()
        |> LoginRequest.encode()

      conn = post(conn, auth_path(conn, :login), proto)

      assert response(conn, 401)
    end
  end
end
