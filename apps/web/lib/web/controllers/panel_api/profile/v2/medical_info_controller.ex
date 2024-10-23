defmodule Web.PanelApi.Profile.V2.MedicalInfoController do
  use Web, :controller

  alias Web.ControllerHelper

  action_fallback Web.FallbackController

  def show(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id

    with {:ok, medical_credentials} <- SpecialistProfile.fetch_medical_credentials(specialist_id),
         {:ok, medical_categories} <- SpecialistProfile.fetch_medical_categories(specialist_id) do
      conn
      |> render("show.proto", %{
        medical_credentials: medical_credentials,
        medical_categories: medical_categories
      })
    end
  end

  @decode Proto.SpecialistProfileV2.UpdateMedicalInfoRequestV2
  def update(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id
    medical_categories = conn.assigns.protobuf.medical_info.medical_categories

    medical_credentials =
      parse_medical_credentials_proto(conn.assigns.protobuf.medical_info.medical_credentials)

    with {:ok,
          %{medical_credentials: medical_credentials, medical_categories: medical_categories}} <-
           SpecialistProfile.update_medical_info(
             specialist_id,
             medical_categories,
             medical_credentials
           ) do
      conn
      |> render("update.proto", %{
        medical_credentials: medical_credentials,
        medical_categories: medical_categories
      })
    end
  end

  defp parse_medical_credentials_proto(params) do
    %{
      board_certification_url: params.board_certification_url,
      board_certification_expiry_date:
        params.board_certification_expiry_date |> ControllerHelper.parse_timestamp(),
      current_state_license_number_url: params.current_state_license_number_url,
      current_state_license_number_expiry_date:
        params.current_state_license_number_expiry_date |> ControllerHelper.parse_timestamp()
    }
  end
end

defmodule Web.PanelApi.Profile.V2.MedicalInfoView do
  use Web, :view

  def render("show.proto", %{
        medical_credentials: medical_credentials,
        medical_categories: medical_categories
      }) do
    %Proto.SpecialistProfileV2.GetMedicalInfoResponseV2{
      medical_info:
        Web.View.SpecialistProfileV2.render_medical_info(medical_credentials, medical_categories)
    }
  end

  def render("update.proto", %{
        medical_credentials: medical_credentials,
        medical_categories: medical_categories
      }) do
    %Proto.SpecialistProfileV2.UpdateMedicalInfoResponseV2{
      medical_info:
        Web.View.SpecialistProfileV2.render_medical_info(medical_credentials, medical_categories)
    }
  end
end
