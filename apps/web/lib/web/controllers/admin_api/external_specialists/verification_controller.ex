defmodule Web.AdminApi.ExternalSpecialists.VerificationController do
  use Web, :controller

  action_fallback Web.FallbackController

  @decode Proto.AdminPanel.VerifyExternalSpecialistRequest
  def verify(conn, params) do
    specialist_id = params["specialist_id"]

    status = conn.assigns.protobuf.status |> to_string()

    with {:ok, _specialist_id} <- Admin.verify_external_specialist(specialist_id, status) do
      resp(conn, 200, "")
    end
  end
end
