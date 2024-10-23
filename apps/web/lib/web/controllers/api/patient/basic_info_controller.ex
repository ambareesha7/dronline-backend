defmodule Web.Api.Patient.BasicInfoController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, _params) do
    patient_id = conn.assigns.current_patient_id

    {:ok, patient} = PatientProfile.fetch_by_id(patient_id)
    {:ok, basic_info} = PatientProfile.fetch_basic_info(patient_id)

    conn |> render("show.proto", %{basic_info: basic_info, patient: patient})
  end

  @decode Proto.PatientProfile.UpdateBasicInfoRequest
  def update(conn, _params) do
    patient_id = conn.assigns.current_patient_id
    basic_info_params = conn.assigns.protobuf.basic_info_params

    params = Web.Parsers.PatientProfile.BasicInfoParams.to_map_params(basic_info_params)

    {:ok, patient} = PatientProfile.fetch_by_id(patient_id)

    with {:ok, basic_info} <- PatientProfile.update_basic_info(params, patient_id) do
      conn |> render("update.proto", %{basic_info: basic_info, patient: patient})
    end
  end
end

defmodule Web.Api.Patient.BasicInfoView do
  use Web, :view

  def render("show.proto", %{basic_info: basic_info, patient: patient}) do
    %Proto.PatientProfile.GetBasicInfoResponse{
      basic_info: Web.View.PatientProfile.render_basic_info(basic_info, patient)
    }
  end

  def render("update.proto", %{basic_info: basic_info, patient: patient}) do
    %Proto.PatientProfile.UpdateBasicInfoResponse{
      basic_info: Web.View.PatientProfile.render_basic_info(basic_info, patient)
    }
  end
end
