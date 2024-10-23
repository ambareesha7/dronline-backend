defmodule EMR.PatientRecords.MedicationsBundleTest do
  use Postgres.DataCase, async: true

  alias EMR.PatientRecords.MedicationsBundle
  alias EMR.PatientRecords.MedicationsBundle.Medication

  describe "create/1" do
    test "creates medications_bundle" do
      patient_id = record_id = specialist_id = 1

      params = %{
        items: [
          %{
            name: "Medication 1",
            direction: "Direction 1",
            quantity: "Quantity 1",
            refills: 1,
            price_aed: 2000
          }
        ]
      }

      assert {:ok, _} =
               MedicationsBundle.create(
                 patient_id,
                 record_id,
                 specialist_id,
                 params
               )

      assert [
               %MedicationsBundle{
                 medications: [
                   %{
                     name: "Medication 1",
                     direction: "Direction 1",
                     quantity: "Quantity 1",
                     refills: 1,
                     price_aed: 2000
                   }
                 ]
               }
             ] = Repo.all(MedicationsBundle)
    end

    test "returns changeset when params are invalid" do
      patient_id = record_id = specialist_id = 1

      invalid_params = %{
        items: []
      }

      assert {:error, %Ecto.Changeset{}} =
               MedicationsBundle.create(patient_id, record_id, specialist_id, invalid_params)
    end
  end

  test "fetch_history_for_record/1 returns correct list" do
    patient_id = record_id = specialist_id = 1

    EMR.Factory.insert(:medications_bundle,
      patient_id: patient_id,
      timeline_id: record_id,
      specialist_id: specialist_id,
      medications: [
        %{
          name: "Medication 1",
          direction: "Direction 1",
          quantity: "Quantity 1",
          refills: 1,
          price_aed: 2000
        }
      ]
    )

    assert {:ok,
            [
              %MedicationsBundle{
                patient_id: 1,
                specialist_id: 1,
                timeline_id: 1,
                medications: [
                  %Medication{
                    name: "Medication 1",
                    direction: "Direction 1",
                    quantity: "Quantity 1",
                    refills: 1,
                    price_aed: 2000
                  }
                ]
              }
            ]} = MedicationsBundle.fetch_history_for_record(record_id)
  end
end
