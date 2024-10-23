defmodule Web.AdminApi.AccountDeletionsControllerTest do
  use Web.ConnCase, async: true

  alias Proto.AdminPanel.GetAccountDeletionsResponse

  describe "GET index" do
    setup [:proto_content, :authenticate_admin]

    test "successfully return all account deletions", %{conn: conn} do
      patient_account_deletion = Authentication.Factory.insert(:patient_account_deletion, %{})

      specialist_account_deletion =
        Authentication.Factory.insert(:specialist_account_deletion, %{})

      conn = get(conn, admin_account_deletions_path(conn, :index))
      response = proto_response(conn, 200, GetAccountDeletionsResponse)

      assert length(response.account_deletions) == 2

      account_deletion_1 =
        Enum.find(response.account_deletions, &(&1.id == patient_account_deletion.id))

      account_deletion_2 =
        Enum.find(response.account_deletions, &(&1.id == specialist_account_deletion.id))

      assert account_deletion_1
      assert {:patient_basic_info, _basic_info} = account_deletion_1.basic_info

      assert account_deletion_2
      assert {:specialist_basic_info, _basic_info} = account_deletion_2.basic_info
    end

    test "return an empty list when there are no account deletions", %{conn: conn} do
      conn = get(conn, admin_account_deletions_path(conn, :index))
      response = proto_response(conn, 200, GetAccountDeletionsResponse)

      assert response.account_deletions == []
    end
  end
end
