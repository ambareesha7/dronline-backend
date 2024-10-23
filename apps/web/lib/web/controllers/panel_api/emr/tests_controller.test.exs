defmodule Web.PanelApi.EMR.TestsControllerTest do
  use Web.ConnCase, async: true

  alias Proto.EMR.GetTestsResponse

  describe "GET index" do
    setup [:authenticate_external_platinum]

    test "returns correct list", %{
      conn: conn,
      current_external: current_external
    } do
      _basic_info =
        SpecialistProfile.Factory.insert(:basic_info, specialist_id: current_external.id)

      patient = PatientProfile.Factory.insert(:patient)
      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id)

      EMR.register_interaction_between(current_external.id, patient.id)

      _basic_info =
        PatientProfile.Factory.insert(:basic_info, patient_id: patient.id, first_name: "Adolf")

      record = EMR.Factory.insert(:manual_record, patient_id: patient.id)

      EMR.Factory.insert(:tests_category, %{id: 1, name: "category 1"})
      EMR.Factory.insert(:test, %{id: 1, category_id: 1, name: "test 1"})
      EMR.Factory.insert(:test, %{id: 2, category_id: 1, name: "test 2"})

      bundle =
        EMR.Factory.insert(:ordered_tests_bundle,
          patient_id: patient.id,
          timeline_id: record.id,
          specialist_id: current_external.id
        )

      _test_1 =
        EMR.Factory.insert(:ordered_test,
          description: "description 1",
          medical_test_id: 1,
          bundle_id: bundle.id
        )

      _test_2 =
        EMR.Factory.insert(:ordered_test,
          description: "description 2",
          medical_test_id: 2,
          bundle_id: bundle.id
        )

      conn = get(conn, panel_emr_tests_path(conn, :index), limit: "1")

      assert %GetTestsResponse{
               bundles: [
                 %Proto.EMR.TestsBundle{
                   specialist_id: specialist_id,
                   patient_id: patient_id,
                   inserted_at: _,
                   tests: [
                     %Proto.EMR.Test{
                       name: "test 1",
                       category_name: "category 1",
                       description: "description 1"
                     },
                     %Proto.EMR.Test{
                       name: "test 2",
                       category_name: "category 1",
                       description: "description 2"
                     }
                   ]
                 }
               ],
               specialists: [_],
               patients: [_],
               next_token: _
             } = proto_response(conn, 200, GetTestsResponse)

      assert patient_id == patient.id
      assert specialist_id == current_external.id
    end
  end
end
