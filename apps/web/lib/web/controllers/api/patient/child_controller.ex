defmodule Web.Api.Patient.ChildController do
  use Web, :controller

  action_fallback Web.FallbackController

  @decode Proto.PatientProfile.AddChildProfileRequest
  def create(conn, _params) do
    adult_patient_id = conn.assigns.current_patient_id
    basic_info_params = conn.assigns.protobuf.basic_info_params

    basic_info_params =
      Web.Parsers.PatientProfile.BasicInfoParams.to_map_params(basic_info_params)

    with {:ok, {child_profile, basic_info}} <-
           PatientProfilesManagement.add_related_child_profile(
             basic_info_params,
             adult_patient_id
           ),
         {:ok, auth_token_entry} <-
           Authentication.generate_auth_token_entry_for_patient(child_profile.id) do
      conn
      |> render("create.proto", %{
        auth_token: auth_token_entry.auth_token,
        basic_info: basic_info,
        patient: child_profile
      })
    end
  end

  def index(conn, _params) do
    adult_patient_id = conn.assigns.current_patient_id
    child_patient_ids = PatientProfilesManagement.get_related_child_patient_ids(adult_patient_id)

    profiles_map = child_patient_ids |> PatientProfile.get_profiles() |> Map.new(&{&1.id, &1})
    {:ok, basic_infos} = PatientProfile.fetch_basic_infos(child_patient_ids)
    basic_infos_map = basic_infos |> Map.new(&{&1.patient_id, &1})

    auth_token_entries_map =
      child_patient_ids
      |> Authentication.get_auth_token_entries()
      |> Map.new(&{&1.patient_id, &1})

    child_profiles =
      for child_id <- child_patient_ids do
        {
          Map.fetch!(basic_infos_map, child_id),
          Map.fetch!(profiles_map, child_id),
          Map.fetch!(auth_token_entries_map, child_id).auth_token
        }
      end

    conn |> render("index.proto", %{child_profiles: child_profiles})
  end
end

defmodule Web.Api.Patient.ChildView do
  use Web, :view

  def render("create.proto", %{auth_token: auth_token, basic_info: basic_info, patient: patient}) do
    %Proto.PatientProfile.AddChildProfileResponse{
      child_profile: Web.View.PatientProfile.render_child_profile(basic_info, patient, auth_token)
    }
  end

  def render("index.proto", %{child_profiles: child_profiles}) do
    %Proto.PatientProfile.GetChildrenProfilesResponse{
      child_profiles:
        Enum.map(child_profiles, fn {basic_info, patient, auth_token} ->
          Web.View.PatientProfile.render_child_profile(basic_info, patient, auth_token)
        end)
    }
  end
end
