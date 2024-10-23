defmodule Web.PanelApi.Profile.MedicalInfoController do
  use Web, :controller

  alias Web.ControllerHelper

  action_fallback Web.FallbackController

  @decode Proto.SpecialistProfile.UpdateMedicalInfoRequest
  def update(conn, _params) do
    %{
      medical_categories: categoires_proto,
      medical_credentials: credentials_proto
    } = conn.assigns.protobuf.medical_info

    specialist_id = conn.assigns.current_specialist_id

    categories_ids = categoires_proto |> parse_categories_proto()
    credentials_params = credentials_proto |> parse_credentials_proto()

    transaction_result =
      Postgres.Repo.transaction(fn ->
        with {:ok, medical_categories} <-
               SpecialistProfile.update_medical_categories(categories_ids, specialist_id),
             {:ok, medical_credentials} <-
               SpecialistProfile.update_medical_credentials(credentials_params, specialist_id) do
          %{medical_categories: medical_categories, medical_credentials: medical_credentials}
        else
          {:error, changeset} ->
            Postgres.Repo.rollback(changeset)
        end
      end)

    with {:ok, medical_info} <- transaction_result do
      render(conn, "update.proto", %{medical_info: medical_info})
    end
  end

  defp parse_categories_proto(categories), do: categories |> Enum.map(& &1.id)

  defp parse_credentials_proto(params) do
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

defmodule Web.PanelApi.Profile.MedicalInfoView do
  use Web, :view

  def render("update.proto", %{medical_info: medical_info}) do
    %Proto.SpecialistProfile.UpdateMedicalInfoResponse{
      medical_info:
        render_one(medical_info, Proto.SpecialistProfileView, "medical_info.proto",
          as: :medical_info
        )
    }
  end
end
