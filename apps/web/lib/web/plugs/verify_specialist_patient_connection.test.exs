defmodule Web.Plugs.VerifySpecialistPatientConnectionTest do
  use Web.ConnCase, async: true

  alias EMR.SpecialistPatientConnections.SpecialistPatientConnection
  alias Web.Plugs.AuthenticateSpecialist
  alias Web.Plugs.VerifySpecialistPatientConnection

  test "returns connection without changes when specialist is rejected external", %{
    conn: orginal_conn
  } do
    specialist = Authentication.Factory.insert(:verified_and_rejected_external)
    patient = PatientProfile.Factory.insert(:patient)

    orginal_conn =
      orginal_conn
      |> Map.put(:params, %{"patient_id" => patient.id})
      |> put_req_header("x-auth-token", specialist.auth_token)
      |> AuthenticateSpecialist.call(%{})

    opts = VerifySpecialistPatientConnection.init(param_name: "patient_id")

    conn =
      orginal_conn
      |> VerifySpecialistPatientConnection.call(opts)

    assert conn == orginal_conn
    refute conn.halted
  end

  test "returns connection without changes when specialist is external and have connection with patient",
       %{
         conn: orginal_conn
       } do
    specialist = Authentication.Factory.insert(:verified_and_approved_external)
    patient = PatientProfile.Factory.insert(:patient)

    SpecialistPatientConnection.create(specialist.id, patient.id)

    orginal_conn =
      orginal_conn
      |> Map.put(:params, %{"patient_id" => patient.id})
      |> put_req_header("x-auth-token", specialist.auth_token)
      |> AuthenticateSpecialist.call(%{})

    opts = VerifySpecialistPatientConnection.init(param_name: "patient_id")

    conn =
      orginal_conn
      |> VerifySpecialistPatientConnection.call(opts)

    assert conn == orginal_conn
    refute conn.halted
  end

  test "returns 403 without changes when specialist is external and have connection with patient",
       %{
         conn: orginal_conn
       } do
    specialist = Authentication.Factory.insert(:verified_and_approved_external)
    patient = PatientProfile.Factory.insert(:patient)

    orginal_conn =
      orginal_conn
      |> Map.put(:params, %{"patient_id" => patient.id})
      |> put_req_header("x-auth-token", specialist.auth_token)
      |> AuthenticateSpecialist.call(%{})
      |> fetch_query_params()

    opts = VerifySpecialistPatientConnection.init(param_name: "patient_id")

    conn =
      orginal_conn
      |> VerifySpecialistPatientConnection.call(opts)

    assert response(conn, 403)
    assert conn.halted
  end

  test "returns connection without changes when specialist is external and have connection with patient (via_timeline)",
       %{
         conn: orginal_conn
       } do
    specialist = Authentication.Factory.insert(:verified_and_approved_external)
    patient = PatientProfile.Factory.insert(:patient)

    timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
    SpecialistPatientConnection.create(specialist.id, patient.id)

    orginal_conn =
      orginal_conn
      |> Map.put(:params, %{"id" => timeline.id})
      |> put_req_header("x-auth-token", specialist.auth_token)
      |> AuthenticateSpecialist.call(%{})

    opts = VerifySpecialistPatientConnection.init(param_name: "id", via_timeline: true)

    conn =
      orginal_conn
      |> VerifySpecialistPatientConnection.call(opts)

    assert conn == orginal_conn
    refute conn.halted
  end
end
