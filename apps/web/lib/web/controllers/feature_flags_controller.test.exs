defmodule Web.PublicApi.FeatureFlagsControllerTest do
  use Web.ConnCase, async: true

  test "verify returns correct result", %{conn: conn} do
    FeatureFlags.Factory.insert(:flag,
      name: "flag_name",
      enabled: true
    )

    FeatureFlags.Factory.insert(:flag,
      name: "flag_name_disabled",
      enabled: false
    )

    conn_2 = conn_3 = conn

    # Enabled flag
    conn = get(conn, feature_flags_path(conn, :verify, "flag_name"))

    assert %Proto.FeatureFlags.VerifyResponse{
             enabled: true
           } = proto_response(conn, 200, Proto.FeatureFlags.VerifyResponse)

    # Disabled flag
    conn_2 = get(conn_2, feature_flags_path(conn_2, :verify, "flag_name_disabled"))

    assert %Proto.FeatureFlags.VerifyResponse{
             enabled: false
           } = proto_response(conn_2, 200, Proto.FeatureFlags.VerifyResponse)

    # Non-existing flag
    conn_3 = get(conn_3, feature_flags_path(conn_3, :verify, "flag_name_non_existing"))

    assert %Proto.FeatureFlags.VerifyResponse{
             enabled: false
           } = proto_response(conn_3, 200, Proto.FeatureFlags.VerifyResponse)
  end
end
