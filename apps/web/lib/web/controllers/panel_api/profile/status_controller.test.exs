defmodule Web.PanelApi.Profile.StatusControllerTest do
  use Web.ConnCase, async: true

  alias Proto.SpecialistProfile.GetStatusResponse

  describe "GET status" do
    setup [:authenticate_external]

    test "success", %{conn: conn} do
      conn = get(conn, panel_profile_status_path(conn, :show))

      assert %GetStatusResponse{
               status: %{
                 onboarding_completed: true,
                 trial_ends_at: trial_ends_at,
                 has_seen_pricing_tables: false
               }
             } = proto_response(conn, 200, GetStatusResponse)

      assert trial_ends_at > Timex.now() |> Timex.shift(months: 2) |> Timex.to_unix()
      assert trial_ends_at < Timex.now() |> Timex.shift(months: 4) |> Timex.to_unix()
    end
  end
end
