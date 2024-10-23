defmodule Web.PanelApi.Membership.PackagesControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Membership.GetPackagesListResponse

  describe "GET index" do
    setup [:proto_content, :authenticate_external]

    test "returns all packages", %{conn: conn} do
      conn = get(conn, panel_membership_packages_path(conn, :index))

      assert %GetPackagesListResponse{packages: packages} =
               proto_response(conn, 200, GetPackagesListResponse)

      assert is_list(packages)
      assert length(packages) > 0
    end
  end
end
