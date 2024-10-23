defmodule Web.Plugs.AuthenticateSpecialistTest do
  use Web.ConnCase, async: true

  alias Web.Plugs.AuthenticateSpecialist

  test "assigns data if token is valid and specialist verified", %{conn: conn} do
    specialist = Authentication.Factory.insert(:verified_and_approved_external)

    conn =
      conn
      |> put_req_header("x-auth-token", specialist.auth_token)
      |> AuthenticateSpecialist.call(%{})

    assert conn.assigns.current_specialist_id == specialist.id
    assert conn.assigns.scopes == [specialist.type, specialist.package_type]
    refute conn.halted
  end

  test "assigns scope 'EXTERNAL_REJECTED' if approval status for external is 'REJECTED'",
       %{conn: conn} do
    specialist = Authentication.Factory.insert(:verified_and_rejected_external)

    conn =
      conn
      |> put_req_header("x-auth-token", specialist.auth_token)
      |> AuthenticateSpecialist.call(%{})

    assert conn.assigns.current_specialist_id == specialist.id
    assert conn.assigns.scopes == ["EXTERNAL_REJECTED", specialist.package_type]
    refute conn.halted
  end

  test "assigns right scope for internals when token is valid and onboarding isn't completed", %{
    conn: conn
  } do
    specialist = Authentication.Factory.insert(:not_onboarded_verified_specialist, type: "NURSE")

    conn =
      conn
      |> put_req_header("x-auth-token", specialist.auth_token)
      |> AuthenticateSpecialist.call(%{})

    assert conn.assigns.current_specialist_id == specialist.id
    assert conn.assigns.scopes == [specialist.type <> "_ONBOARDING", specialist.package_type]
    refute conn.halted
  end

  test "assigns right scope for internals when token is valid and onboarding is completed", %{
    conn: conn
  } do
    specialist = Authentication.Factory.insert(:verified_specialist, type: "NURSE")
    SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

    conn =
      conn
      |> put_req_header("x-auth-token", specialist.auth_token)
      |> AuthenticateSpecialist.call(%{})

    assert conn.assigns.current_specialist_id == specialist.id
    assert conn.assigns.scopes == [specialist.type, specialist.package_type]
    refute conn.halted
  end

  test "returns 401 if specialist is unverified", %{conn: conn} do
    unverified_specialist = Authentication.Factory.insert(:specialist)

    conn =
      conn
      |> put_req_header("x-auth-token", unverified_specialist.auth_token)
      |> AuthenticateSpecialist.call(%{})

    assert response(conn, 401)
    assert conn.halted
  end

  test "returns 401 if token is missing", %{conn: conn} do
    conn = AuthenticateSpecialist.call(conn, %{})

    assert response(conn, 401)
    assert conn.halted
  end
end
