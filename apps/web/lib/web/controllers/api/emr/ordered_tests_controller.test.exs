defmodule Web.Api.EMR.OrderTestsControllerTest do
  use Web.ConnCase, async: true

  alias Proto.EMR.GetOrderedTestsHistoryResponse
  alias Proto.EMR.GetTestResponse

  describe "GET history_for_record" do
    setup [:authenticate_patient]

    test "returns correct list", %{
      conn: conn,
      current_patient: current_patient
    } do
      specialist = Authentication.Factory.insert(:verified_specialist)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      record = EMR.Factory.insert(:manual_record, patient_id: current_patient.id)

      EMR.Factory.insert(:tests_category, %{id: 1, name: "category 1"})
      EMR.Factory.insert(:test, %{id: 1, category_id: 1, name: "test 1"})

      bundle =
        EMR.Factory.insert(:ordered_tests_bundle,
          patient_id: current_patient.id,
          timeline_id: record.id,
          specialist_id: specialist.id
        )

      EMR.Factory.insert(:ordered_test,
        description: "description 1",
        medical_test_id: 1,
        bundle_id: bundle.id
      )

      path = emr_ordered_tests_path(conn, :history_for_record, record.id)
      conn = get(conn, path)

      assert %GetOrderedTestsHistoryResponse{
               bundles: [
                 %Proto.EMR.TestsBundle{
                   inserted_at: _inserted_at,
                   specialist_id: specialist_id,
                   tests: [
                     %Proto.EMR.Test{
                       name: "test 1",
                       description: "description 1",
                       category_name: "category 1"
                     }
                   ]
                 }
               ]
             } = proto_response(conn, 200, GetOrderedTestsHistoryResponse)

      assert specialist_id == specialist.id
    end
  end

  describe "GET show" do
    setup [:authenticate_patient]

    test "succeeds", %{conn: conn, current_patient: current_patient} do
      specialist = Authentication.Factory.insert(:verified_specialist)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      record = EMR.Factory.insert(:manual_record, patient_id: current_patient.id)

      EMR.Factory.insert(:tests_category, %{id: 1, name: "category 1"})
      EMR.Factory.insert(:test, %{id: 1, category_id: 1, name: "test 1"})

      bundle =
        EMR.Factory.insert(:ordered_tests_bundle,
          patient_id: current_patient.id,
          timeline_id: record.id,
          specialist_id: specialist.id
        )

      EMR.Factory.insert(:ordered_test,
        description: "description 1",
        medical_test_id: 1,
        bundle_id: bundle.id
      )

      conn = get(conn, emr_ordered_tests_path(conn, :show, record.id, bundle.id))

      assert %GetTestResponse{
               bundle: %Proto.EMR.TestsBundle{
                 specialist_id: specialist_id
               },
               specialist: %Proto.Generics.Specialist{
                 id: specialist_id
               }
             } = proto_response(conn, 200, GetTestResponse)
    end
  end
end
