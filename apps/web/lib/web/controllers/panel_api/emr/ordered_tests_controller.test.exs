defmodule Web.PanelApi.EMR.OrderTestsControllerTest do
  use Web.ConnCase, async: true

  alias Proto.EMR.CreateOrderedTestsRequest
  alias Proto.EMR.CreateOrderedTestsResponse
  alias Proto.EMR.GetOrderedTestsHistoryResponse

  describe "POST create" do
    setup [:authenticate_external, :proto_content]

    test "creates vitals and returns associated data", %{
      conn: conn,
      current_external: current_external
    } do
      _basic_info =
        SpecialistProfile.Factory.insert(:basic_info, specialist_id: current_external.id)

      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:manual_record, patient_id: patient.id)

      EMR.Factory.insert(:tests_category, %{id: 1, name: "category 1"})
      EMR.Factory.insert(:test, %{id: 1, category_id: 1, name: "test 1"})
      EMR.Factory.insert(:test, %{id: 2, category_id: 1, name: "ignored"})

      proto =
        %CreateOrderedTestsRequest{
          items: [
            %Proto.EMR.OrderedTestsParamsItem{
              medical_test_id: 1,
              description: "description 1"
            }
          ]
        }
        |> CreateOrderedTestsRequest.encode()

      conn = post(conn, panel_emr_ordered_tests_path(conn, :create, patient, record), proto)

      assert %CreateOrderedTestsResponse{
               items: [
                 %Proto.EMR.OrderedTestsItem{
                   test: %Proto.EMR.MedicalTest{
                     id: 1,
                     name: "test 1"
                   },
                   description: "description 1"
                 }
               ],
               specialists: [
                 %Proto.Generics.Specialist{id: returned_specialist_id}
               ]
             } = proto_response(conn, 200, CreateOrderedTestsResponse)

      assert returned_specialist_id == current_external.id
    end
  end

  describe "GET history_for_record" do
    setup [:authenticate_external]

    test "returns correct list", %{
      conn: conn,
      current_external: current_external
    } do
      _basic_info =
        SpecialistProfile.Factory.insert(:basic_info, specialist_id: current_external.id)

      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:manual_record, patient_id: patient.id)

      EMR.Factory.insert(:tests_category, %{id: 1, name: "category 1"})
      EMR.Factory.insert(:test, %{id: 1, category_id: 1, name: "test 1"})

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

      path = panel_emr_ordered_tests_path(conn, :history_for_record, patient.id, record.id)
      conn = get(conn, path)

      assert %GetOrderedTestsHistoryResponse{
               bundles: [
                 %Proto.EMR.TestsBundle{
                   inserted_at: _inserted_at,
                   specialist_id: specialist_id,
                   tests: [
                     %Proto.EMR.Test{
                       name: "test 1",
                       description: "description 1"
                     }
                   ]
                 }
               ]
             } = proto_response(conn, 200, GetOrderedTestsHistoryResponse)

      assert specialist_id == current_external.id
    end
  end
end
