defmodule EMR.PatientRecords.OrderedTestsBundleTest do
  use Postgres.DataCase, async: true

  alias EMR.PatientRecords.MedicalLibrary.Test
  alias EMR.PatientRecords.MedicalLibrary.TestsCategory
  alias EMR.PatientRecords.OrderedTest
  alias EMR.PatientRecords.OrderedTestsBundle

  describe "create/1" do
    test "creates ordered_tests_bundle and ordered_tests" do
      EMR.Factory.insert(:tests_category, %{id: 1, name: "category_1"})

      [
        %{id: 1, category_id: 1, name: "test_1"},
        %{id: 2, category_id: 1, name: "test_2"}
      ]
      |> Enum.each(fn test ->
        EMR.Factory.insert(:test, test)
      end)

      patient_id = record_id = specialist_id = 1

      params = %{
        items: [
          %{
            medical_test_id: 1,
            description: "test 1"
          },
          %{
            medical_test_id: 2,
            description: "test 2"
          }
        ]
      }

      assert {:ok, _ordered_tests_bundle} =
               OrderedTestsBundle.create(
                 patient_id,
                 record_id,
                 specialist_id,
                 params
               )
    end

    test "returns changeset when params are invalid" do
      patient_id = record_id = specialist_id = 1

      params = %{
        items: []
      }

      assert {:error, %Ecto.Changeset{}} =
               OrderedTestsBundle.create(patient_id, record_id, specialist_id, params)
    end
  end

  test "fetch_history_for_record/1 returns correct list" do
    patient_id = 1
    record_id = 2
    specialist_id = 3

    EMR.Factory.insert(:tests_category, %{id: 1, name: "category 1"})
    EMR.Factory.insert(:test, %{id: 1, category_id: 1, name: "test 1"})
    EMR.Factory.insert(:test, %{id: 2, category_id: 1, name: "test 2"})

    bundle_1 =
      EMR.Factory.insert(:ordered_tests_bundle,
        patient_id: patient_id,
        timeline_id: record_id,
        specialist_id: specialist_id
      )

    # Ignored - record_id doesn't match
    bundle_2 =
      EMR.Factory.insert(:ordered_tests_bundle,
        patient_id: patient_id,
        timeline_id: 42,
        specialist_id: specialist_id
      )

    _test_1 =
      EMR.Factory.insert(:ordered_test,
        description: "test 1 description",
        medical_test_id: 1,
        bundle_id: bundle_1.id
      )

    _test_2 =
      EMR.Factory.insert(:ordered_test,
        description: "test 2 description",
        medical_test_id: 2,
        bundle_id: bundle_2.id
      )

    assert {:ok,
            [
              %OrderedTestsBundle{
                ordered_tests: [
                  %OrderedTest{
                    description: "test 1 description",
                    medical_test: %Test{
                      name: "test 1",
                      medical_tests_category: %TestsCategory{
                        name: "category 1"
                      }
                    }
                  }
                ]
              }
            ]} = OrderedTestsBundle.fetch_history_for_record(record_id)
  end
end
