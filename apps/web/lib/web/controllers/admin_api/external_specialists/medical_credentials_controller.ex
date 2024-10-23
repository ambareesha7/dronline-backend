defmodule Web.AdminApi.ExternalSpecialists.MedicalCredentialsController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, params) do
    specialist_id = params["specialist_id"]

    {:ok, medical_credentials} = SpecialistProfile.fetch_medical_credentials(specialist_id)

    conn
    |> put_view(Web.AdminApi.Specialists.MedicalCredentialsView)
    |> render("show.proto", %{medical_credentials: medical_credentials})
  end

  @decode Proto.SpecialistProfile.UpdateMedicalCredentialsRequest
  def update(conn, params) do
    specialist_id = params["specialist_id"] |> String.to_integer()
    medical_credentials_proto = conn.assigns.protobuf.medical_credentials

    with {:ok, medical_credentials} <-
           SpecialistProfile.update_medical_credentials(medical_credentials_proto, specialist_id) do
      conn
      |> put_view(Web.AdminApi.Specialists.MedicalCredentialsView)
      |> render("update.proto", %{medical_credentials: medical_credentials})
    end
  end
end
