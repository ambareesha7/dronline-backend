defmodule Web.Api.NewsletterController do
  use Web, :controller

  action_fallback Web.FallbackController

  @decode Proto.Newsletter.SubscribeRequest
  def subscribe(conn, _params) do
    email = conn.assigns.protobuf.email
    phone_number = conn.assigns.protobuf.phone_number

    with {:ok, _newsletter} <- Admin.subscribe_to_newsletter(email, phone_number) do
      send_resp(conn, 201, "")
    end
  end
end
