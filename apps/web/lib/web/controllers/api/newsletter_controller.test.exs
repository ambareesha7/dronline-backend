defmodule Web.Api.NewsletterControllerTest do
  use Web.ConnCase, async: true
  use Mockery

  alias Proto.Newsletter.SubscribeRequest

  describe "POST subscribe" do
    setup [:proto_content]

    test "success with existing patient", %{conn: conn} do
      proto =
        %{
          email: "office@appunite.com",
          phone_number: "+48532568641"
        }
        |> SubscribeRequest.new()
        |> SubscribeRequest.encode()

      conn = post(conn, newsletter_path(conn, :subscribe), proto)

      assert response(conn, 201)
    end
  end
end
