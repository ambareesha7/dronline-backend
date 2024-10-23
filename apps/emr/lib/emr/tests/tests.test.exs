defmodule EMR.TestsTest do
  use Postgres.DataCase, async: true

  alias EMR.Tests
  alias EMR.Tests.OrderedTestsBundle

  describe "get_for_specialist/1" do
    test "returns list of tests, with pagination" do
      patient = PatientProfile.Factory.insert(:patient)
      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id)
      specialist = Authentication.Factory.insert(:verified_and_approved_external)

      EMR.register_interaction_between(specialist.id, patient.id)

      EMR.Factory.insert(:tests_category, %{id: 1, name: "category_1"})

      [
        %{id: 1, category_id: 1, name: "test_1"},
        %{id: 2, category_id: 1, name: "test_2"}
      ]
      |> Enum.each(&EMR.Factory.insert(:test, &1))

      ordered_tests_bundle_1 =
        EMR.Factory.insert(:ordered_tests_bundle,
          patient_id: patient.id,
          specialist_id: specialist.id,
          timeline_id: 1
        )

      ordered_tests_bundle_2 =
        EMR.Factory.insert(:ordered_tests_bundle,
          patient_id: patient.id,
          specialist_id: specialist.id,
          timeline_id: 1
        )

      EMR.Factory.insert(:ordered_test, %{
        bundle_id: ordered_tests_bundle_1.id,
        medical_test_id: 1,
        description: "ordered_test_1_desc"
      })

      EMR.Factory.insert(:ordered_test, %{
        bundle_id: ordered_tests_bundle_2.id,
        medical_test_id: 2,
        description: "ordered_test_2_desc"
      })

      # No pagination
      assert {:ok,
              [
                %OrderedTestsBundle{
                  tests: [_]
                },
                %OrderedTestsBundle{
                  tests: [_]
                }
              ], nil} = Tests.get_for_specialist(specialist.id, %{})

      # Pagination
      params = %{"limit" => "1"}

      assert {:ok, [tests_bundle], next_token} = Tests.get_for_specialist(specialist.id, params)

      assert tests_bundle.inserted_at == ordered_tests_bundle_2.inserted_at
      assert next_token == ordered_tests_bundle_1.inserted_at

      params = %{"limit" => "1", "next_token" => Tests.encode_next_token(next_token)}

      assert {:ok, [tests_bundle], nil} = Tests.get_for_specialist(specialist.id, params)

      assert tests_bundle.inserted_at == ordered_tests_bundle_1.inserted_at
    end
  end
end
