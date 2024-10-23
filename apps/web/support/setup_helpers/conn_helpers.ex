defmodule Web.ConnHelpers do
  import Plug.Conn

  def proto_content(opts) do
    conn =
      opts
      |> Map.get(:conn, Phoenix.ConnTest.build_conn())
      |> put_req_header("content-type", "application/x-protobuf")

    result = Map.merge(opts, %{conn: conn})

    {:ok, result}
  end

  def accept_proto(opts) do
    conn =
      opts
      |> Map.get(:conn, Phoenix.ConnTest.build_conn())
      |> put_req_header("accept", "application/x-protobuf")

    result = Map.merge(opts, %{conn: conn})

    {:ok, result}
  end

  def authenticate_admin(opts) do
    admin = Authentication.Factory.insert(:admin)

    conn =
      opts
      |> Map.get(:conn, Phoenix.ConnTest.build_conn())
      |> put_req_header("x-auth-token", admin.auth_token)

    result = Map.merge(opts, %{conn: conn, current_admin: admin})

    {:ok, result}
  end

  def authenticate_patient(opts) do
    patient = PatientProfile.Factory.insert(:patient)

    {:ok, auth_token_entry} =
      Authentication.Patient.AuthTokenEntry.create(patient.id)

    conn =
      opts
      |> Map.get(:conn, Phoenix.ConnTest.build_conn())
      |> put_req_header("x-auth-token", auth_token_entry.auth_token)

    result = Map.merge(opts, %{conn: conn, current_patient: patient})

    {:ok, result}
  end

  def authenticate_gp(opts) do
    gp = Authentication.Factory.insert(:verified_specialist, type: "GP")
    SpecialistProfile.Factory.insert(:basic_info, specialist_id: gp.id)

    conn =
      opts
      |> Map.get(:conn, Phoenix.ConnTest.build_conn())
      |> put_req_header("x-auth-token", gp.auth_token)

    result = Map.merge(opts, %{conn: conn, current_gp: gp})

    {:ok, result}
  end

  def authenticate_nurse(opts) do
    nurse = Authentication.Factory.insert(:verified_specialist, type: "NURSE")
    SpecialistProfile.Factory.insert(:basic_info, specialist_id: nurse.id)

    conn =
      opts
      |> Map.get(:conn, Phoenix.ConnTest.build_conn())
      |> put_req_header("x-auth-token", nurse.auth_token)

    result = Map.merge(opts, %{conn: conn, current_nurse: nurse})

    {:ok, result}
  end

  def authenticate_external(opts) do
    external = Authentication.Factory.insert(:verified_and_approved_external)

    conn =
      opts
      |> Map.get(:conn, Phoenix.ConnTest.build_conn())
      |> put_req_header("x-auth-token", external.auth_token)

    result = Map.merge(opts, %{conn: conn, current_external: external})

    {:ok, result}
  end

  def authenticate_external_platinum(opts) do
    external = Authentication.Factory.insert(:verified_and_approved_external)

    Membership.Factory.insert(:accepted_subscription,
      specialist_id: external.id,
      type: "PLATINUM"
    )

    conn =
      opts
      |> Map.get(:conn, Phoenix.ConnTest.build_conn())
      |> put_req_header("x-auth-token", external.auth_token)

    result = Map.merge(opts, %{conn: conn, current_external: external})

    {:ok, result}
  end
end
