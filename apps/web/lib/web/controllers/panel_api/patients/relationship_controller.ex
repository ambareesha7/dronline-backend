defmodule Web.PanelApi.Patients.RelationshipController do
  use Web, :controller

  action_fallback Web.FallbackController

  plug Web.Plugs.VerifySpecialistPatientConnection, param_name: "patient_id"

  def show(conn, params) do
    %{"patient_id" => patient_id} = params

    with {:ok, _patient} <- PatientProfile.fetch_by_id(patient_id) do
      relationship_data = get_relationship_data(patient_id)

      conn |> render("show.proto", %{relationship_data: relationship_data})
    end
  end

  defp get_relationship_data(patient_id) do
    case PatientProfilesManagement.get_related_adult_patient_id(patient_id) do
      nil ->
        patients_generic_data =
          patient_id
          |> PatientProfilesManagement.get_related_child_patient_ids()
          |> Web.PatientGenericData.get_by_ids()

        {:children, patients_generic_data}

      adult_patient_id ->
        {:adult, Web.PatientGenericData.get_by_id(adult_patient_id)}
    end
  end
end

defmodule Web.PanelApi.Patients.RelationshipView do
  use Web, :view

  def render("show.proto", %{relationship_data: relationship_data}) do
    %Proto.PatientProfile.GetRelationshipResponse{
      related_profiles: parse_relationship_data(relationship_data)
    }
  end

  defp parse_relationship_data({:adult, patient_generic_data}) do
    {:adult, Web.View.Generics.render_patient(patient_generic_data)}
  end

  defp parse_relationship_data({:children, patients_generic_data}) do
    {:children, parse_children_list(patients_generic_data)}
  end

  defp parse_children_list(patients_generic_data) do
    %Proto.PatientProfile.ChildrenList{
      children: Enum.map(patients_generic_data, &Web.View.Generics.render_patient/1)
    }
  end
end
