defmodule Web.PanelApi.Patients.RelationshipControllerTest do
  use Web.ConnCase, async: true

  alias Proto.PatientProfile.GetRelationshipResponse

  alias Proto.PatientProfile.ChildrenList

  describe "GET show" do
    setup [:authenticate_gp]

    test "returns adult patient for provided child patient", %{conn: conn} do
      child_patient = PatientProfile.Factory.insert(:patient)
      adult_patient = PatientProfile.Factory.insert(:patient)
      _ = PatientProfile.Factory.insert(:basic_info, patient_id: adult_patient.id)

      cmd = %PatientProfilesManagement.Commands.RegisterFamilyRelationship{
        adult_patient_id: adult_patient.id,
        child_patient_id: child_patient.id
      }

      _ = PatientProfilesManagement.FamilyRelationship.register_family_relationship(cmd)

      conn = get(conn, panel_patients_relationship_path(conn, :show, child_patient))

      assert %GetRelationshipResponse{related_profiles: {:adult, %Proto.Generics.Patient{}}} =
               proto_response(conn, 200, GetRelationshipResponse)
    end

    test "returns children patients for provided adult patient", %{conn: conn} do
      adult_patient = PatientProfile.Factory.insert(:patient)
      child_patient = PatientProfile.Factory.insert(:patient)
      _ = PatientProfile.Factory.insert(:basic_info, patient_id: child_patient.id)

      cmd = %PatientProfilesManagement.Commands.RegisterFamilyRelationship{
        adult_patient_id: adult_patient.id,
        child_patient_id: child_patient.id
      }

      _ = PatientProfilesManagement.FamilyRelationship.register_family_relationship(cmd)

      conn = get(conn, panel_patients_relationship_path(conn, :show, adult_patient))

      assert %GetRelationshipResponse{
               related_profiles: {:children, %ChildrenList{children: [%Proto.Generics.Patient{}]}}
             } = proto_response(conn, 200, GetRelationshipResponse)
    end

    test "returns 404 when patient doesn't exist", %{conn: conn} do
      conn = get(conn, panel_patients_relationship_path(conn, :show, 0))

      assert response(conn, 404)
    end
  end
end
