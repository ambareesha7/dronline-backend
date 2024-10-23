defmodule Web.PanelApi.Profile.MedicalCredentialsController do
  use Web, :controller

  alias Web.ControllerHelper

  action_fallback Web.FallbackController

  def show(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id

    {:ok, medical_credentials} = SpecialistProfile.fetch_medical_credentials(specialist_id)

    conn
    |> render("show.proto", %{medical_credentials: medical_credentials})
  end

  @decode Proto.SpecialistProfile.UpdateMedicalCredentialsRequest
  def update(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id
    medical_credentials_proto = conn.assigns.protobuf.medical_credentials

    params = medical_credentials_proto |> parse_proto()

    with {:ok, medical_credentials} <-
           SpecialistProfile.update_medical_credentials(params, specialist_id) do
      conn
      |> render("update.proto", %{medical_credentials: medical_credentials})
    end
  end

  defp parse_proto(params) do
    %{
      dea_number_url: params.dea_number_url,
      dea_number_expiry_date: params.dea_number_expiry_date |> ControllerHelper.parse_timestamp(),
      board_certification_url: params.board_certification_url,
      board_certification_expiry_date:
        params.board_certification_expiry_date |> ControllerHelper.parse_timestamp(),
      current_state_license_number_url: params.current_state_license_number_url,
      current_state_license_number_expiry_date:
        params.current_state_license_number_expiry_date |> ControllerHelper.parse_timestamp()
    }
  end
end
