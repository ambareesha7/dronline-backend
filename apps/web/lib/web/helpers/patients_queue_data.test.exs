defmodule Web.PatientsQueueDataTest do
  use Postgres.DataCase, async: true

  describe "get_by_gp_id/1" do
    setup do
      gp = Authentication.Factory.insert(:specialist, type: "GP")
      patient = PatientProfile.Factory.insert(:patient)
      patient_basic_info = PatientProfile.Factory.insert(:basic_info, %{patient_id: patient.id})

      Authentication.Patient.Account.create(%{
        main_patient_id: patient.id,
        firebase_id: "firebase_id#{:rand.uniform()}",
        phone_number: patient.phone_number,
        is_signed_up: true
      })

      {:ok, team} = Teams.create_team(:rand.uniform(1000), %{})
      :ok = Teams.add_to_team(team_id: team.id, specialist_id: gp.id)
      Teams.accept_invitation(team_id: team.id, specialist_id: gp.id)
      Application.put_env(:urgent_care, :default_clinic_id, Integer.to_string(team.id))

      [gp_id: gp.id, patient: patient, patient_basic_info: patient_basic_info]
    end

    test "returns complete data collection for valid patients", %{
      gp_id: gp_id,
      patient: %{id: patient_id} = patient,
      patient_basic_info: patient_basic_info
    } do
      add_to_queue(patient)

      assert [
               %Web.PatientsQueueData{
                 patient: %{
                   basic_info: patient_basic_info_result,
                   patient_id: ^patient_id,
                   account: %{is_signed_up: true, phone_number: phone_number},
                   related_adult_patient_id: nil
                 },
                 record_id: record_id,
                 inserted_at: inserted_at
               }
             ] =
               Web.PatientsQueueData.get_by_gp_id(gp_id)

      assert record_id
      assert inserted_at
      assert phone_number

      basic_info_fields = [:first_name, :last_name, :patient_id, :avatar_resource_path]

      assert Map.take(patient_basic_info_result, basic_info_fields) ==
               Map.take(patient_basic_info, basic_info_fields)
    end

    test "returns empty list, when there is no patient in the queue", %{gp_id: gp_id} do
      assert Web.PatientsQueueData.get_by_gp_id(gp_id) == []
    end

    test "returns error for patient with no account", %{gp_id: gp_id} do
      patient = PatientProfile.Factory.insert(:patient)
      add_to_queue(patient)

      assert {:error, "No account for patients with ids [#{patient.id}]"} ==
               Web.PatientsQueueData.get_by_gp_id(gp_id)
    end
  end

  defp add_to_queue(patient) do
    UrgentCare.PatientsQueue.add_to_queue(%{
      patient_id: patient.id,
      record_id: EMR.Factory.insert(:automatic_record, patient_id: patient.id).id,
      patient_location: %{latitude: 10.0, longitude: 10.0},
      device_id: UUID.uuid4(),
      payment_params: %{
        transaction_reference: "transaction_reference",
        payment_method: :TELR,
        amount: "299",
        currency: "USD",
        urgent_care_request_id: UUID.uuid4()
      }
    })
  end
end
