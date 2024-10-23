defmodule Web.Plugs.SentryUserContextTest do
  use Web.ConnCase, async: true
  import Plug.Conn

  alias Web.Plugs.SentryUserContext

  test "when conn has assigned patient", %{conn: conn} do
    _conn =
      conn
      |> put_req_header("x-forwarded-for", "123.456.789.000")
      |> assign(:current_patient_id, 0)
      |> SentryUserContext.call([])

    assert Sentry.Context.get_all() == %{
             user: %{"id" => "PATIENT 0"},
             breadcrumbs: [],
             extra: %{},
             request: %{},
             tags: %{}
           }
  end

  test "when conn has assigned specialist", %{conn: conn} do
    _conn =
      conn
      |> put_req_header("x-forwarded-for", "123.456.789.000")
      |> assign(:current_specialist_id, 0)
      |> SentryUserContext.call([])

    assert Sentry.Context.get_all() == %{
             user: %{"id" => "SPECIALIST 0"},
             breadcrumbs: [],
             extra: %{},
             request: %{},
             tags: %{}
           }
  end

  test "when conn has assigned admin", %{conn: conn} do
    _conn =
      conn
      |> put_req_header("x-forwarded-for", "123.456.789.000")
      |> assign(:current_admin_id, 0)
      |> SentryUserContext.call([])

    assert Sentry.Context.get_all() == %{
             user: %{"id" => "ADMIN 0"},
             breadcrumbs: [],
             extra: %{},
             request: %{},
             tags: %{}
           }
  end

  test "when conn doesn't have assigned user", %{conn: conn} do
    _conn =
      conn
      |> put_req_header("x-forwarded-for", "123.456.789.000")
      |> SentryUserContext.call([])

    assert Sentry.Context.get_all() == %{
             user: %{"ip_address" => "123.456.789.000"},
             breadcrumbs: [],
             extra: %{},
             request: %{},
             tags: %{}
           }
  end
end
