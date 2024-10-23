defmodule Web.PatientGenericDataTest do
  use Postgres.DataCase, async: true

  describe "get_by_ids/1" do
    test "rejects invalid id (nil)" do
      assert Web.PatientGenericData.get_by_ids([nil]) == []
    end

    test "rejects patients that doesn't have basic_info" do
      assert Web.PatientGenericData.get_by_ids([1]) == []
    end

    test "returns complete data collection for valid patients" do
      %{id: patient_id} = PatientProfile.Factory.insert(:patient)
      basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient_id)

      assert [
               %Web.PatientGenericData{
                 basic_info: %PatientProfile.BasicInfo{},
                 patient_id: ^patient_id
               }
             ] = Web.PatientGenericData.get_by_ids([basic_info.patient_id])
    end
  end

  describe "get_by_id/1" do
    test "returns correct data for a patient" do
      %{id: patient_id} = PatientProfile.Factory.insert(:patient)
      basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient_id)

      basic_info
      |> Ecto.Changeset.change(%{
        is_insured: true,
        insurance_provider_name: "provider_name",
        insurance_member_id: "member_id"
      })
      |> Repo.update()

      assert [
               %Web.PatientGenericData{
                 basic_info: %PatientProfile.BasicInfo{
                   birth_date: _,
                   email: _,
                   first_name: _,
                   last_name: _,
                   title: _,
                   gender: _,
                   is_insured: true,
                   insurance_provider_name: "provider_name",
                   insurance_member_id: "member_id"
                 },
                 patient_id: ^patient_id
               }
             ] = Web.PatientGenericData.get_by_ids([basic_info.patient_id])
    end
  end
end
