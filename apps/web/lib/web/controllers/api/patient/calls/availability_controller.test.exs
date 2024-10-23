defmodule Web.Api.CallControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Calls.LocalClinicResponse

  setup [:authenticate_patient]

  test "GET /local_clinic shows the nearest clinic", %{
    conn: conn
  } do
    lat = 52.00
    lon = 18.00

    resp = get(conn, "/api/calls/local_clinic?lat=#{lat}&lon=#{lon}")
    assert %{clinic: nil} = proto_response(resp, 200, LocalClinicResponse)

    {:ok, _} =
      Teams.create_team(random_id(), %{location: %Geo.Point{coordinates: {lat, lon}, srid: 4326}})

    resp = get(conn, "/api/calls/local_clinic?lat=#{lat}&lon=#{lon}")
    assert %{clinic: {:local_clinic, _}} = proto_response(resp, 200, LocalClinicResponse)
  end

  defp random_id, do: :rand.uniform(1000)
end
