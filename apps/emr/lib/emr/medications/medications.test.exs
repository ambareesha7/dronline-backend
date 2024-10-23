defmodule EMR.MedicationsTest do
  use Postgres.DataCase, async: true

  alias EMR.Medications
  alias EMR.Medications.MedicationsBundle

  describe "get_for_specialist/1" do
    test "returns list of medications, with pagination" do
      patient = PatientProfile.Factory.insert(:patient)
      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id)

      specialist = Authentication.Factory.insert(:verified_and_approved_external)

      EMR.register_interaction_between(specialist.id, patient.id)

      EMR.Factory.insert(:tests_category, %{id: 1, name: "category_1"})

      medications_bundle_1 =
        EMR.Factory.insert(:medications_bundle,
          patient_id: patient.id,
          specialist_id: specialist.id,
          medications: [
            %{
              name: "medication_1"
            }
          ],
          timeline_id: 1
        )

      medications_bundle_2 =
        EMR.Factory.insert(:medications_bundle,
          patient_id: patient.id,
          specialist_id: specialist.id,
          medications: [
            %{
              name: "medication_1"
            },
            %{
              name: "medication_2"
            }
          ],
          timeline_id: 1
        )

      # No pagination
      assert {:ok,
              [
                %MedicationsBundle{
                  specialist_id: _,
                  patient_id: _,
                  medications: [_, _]
                },
                %MedicationsBundle{
                  specialist_id: _,
                  patient_id: _,
                  medications: [_]
                }
              ], nil} = Medications.get_for_specialist(specialist.id, %{})

      # Pagination
      params = %{"limit" => "1"}

      assert {:ok, [medications_bundle], next_token} =
               Medications.get_for_specialist(specialist.id, params)

      assert medications_bundle.inserted_at == medications_bundle_2.inserted_at
      assert next_token == medications_bundle_1.inserted_at

      params = %{"limit" => "1", "next_token" => Medications.encode_next_token(next_token)}

      assert {:ok, [medications_bundle], nil} =
               Medications.get_for_specialist(specialist.id, params)

      assert medications_bundle.inserted_at == medications_bundle_1.inserted_at
    end
  end
end
