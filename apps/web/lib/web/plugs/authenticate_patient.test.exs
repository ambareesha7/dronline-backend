defmodule Web.Plugs.AuthenticatePatientTest do
  use Web.ConnCase, async: true

  alias Web.Plugs.AuthenticatePatient

  test "assigns patient id if token is valid", %{conn: conn} do
    patient = PatientProfile.Factory.insert(:patient)
    {:ok, auth_token_entry} = Authentication.Patient.AuthTokenEntry.create(patient.id)

    conn =
      conn
      |> put_req_header("x-auth-token", auth_token_entry.auth_token)
      |> AuthenticatePatient.call(%{})

    assert conn.assigns.current_patient_id == patient.id
    refute conn.halted
  end

  test "returns 401 if token is missing", %{conn: conn} do
    conn = AuthenticatePatient.call(conn, %{})

    assert response(conn, 401)
    assert conn.halted
  end
end
