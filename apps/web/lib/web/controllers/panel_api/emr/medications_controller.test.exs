defmodule Web.PanelApi.EMR.MedicationsControllerTest do
  use Web.ConnCase, async: true

  alias Proto.EMR.AssignMedicationsRequest

  describe "POST create" do
    setup [:authenticate_external, :proto_content]

    test "creates medications", %{
      conn: conn,
      current_external: current_external
    } do
      _basic_info =
        SpecialistProfile.Factory.insert(:basic_info, specialist_id: current_external.id)

      patient = PatientProfile.Factory.insert(:patient)
      record = EMR.Factory.insert(:manual_record, patient_id: patient.id)

      proto =
        %AssignMedicationsRequest{
          items: [
            %Proto.EMR.MedicationsItem{
              name: "Medication 1",
              direction: "Direction 1",
              quantity: "Quantity 1",
              refills: 1,
              price_aed: 2000,
              medication_id: "1"
            }
          ]
        }
        |> AssignMedicationsRequest.encode()

      conn = post(conn, panel_emr_medications_path(conn, :create, patient, record), proto)

      assert response(conn, 200) == ""
    end
  end

  describe "GET index" do
    setup [:authenticate_external_platinum]

    test "returns correct list with default medication value", %{
      conn: conn,
      current_external: current_external
    } do
      _basic_info =
        SpecialistProfile.Factory.insert(:basic_info, specialist_id: current_external.id)

      patient = PatientProfile.Factory.insert(:patient)
      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id)

      EMR.register_interaction_between(current_external.id, patient.id)

      _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)

      _medications_bundle_1 =
        EMR.Factory.insert(:medications_bundle,
          patient_id: patient.id,
          specialist_id: current_external.id,
          medications: [
            %{
              name: "medication_1",
              medication_id: "1"
            }
          ],
          timeline_id: 1
        )

      _medications_bundle_2 =
        EMR.Factory.insert(:medications_bundle,
          patient_id: patient.id,
          specialist_id: current_external.id,
          medications: [
            %{
              name: "medication_1",
              medication_id: "1"
            },
            %{
              name: "medication_2",
              medication_id: "1"
            }
          ],
          timeline_id: 1
        )

      conn = get(conn, panel_emr_medications_path(conn, :index), limit: "1")

      assert %Proto.EMR.GetMedicationsResponse{
               bundles: [
                 %Proto.EMR.MedicationsBundle{
                   patient_id: patient_id,
                   specialist_id: specialist_id,
                   medications: [medication, _],
                   inserted_at: _
                 }
               ],
               specialists: [_],
               patients: [_],
               next_token: _
             } = proto_response(conn, 200, Proto.EMR.GetMedicationsResponse)

      assert patient_id == patient.id
      assert specialist_id == current_external.id

      assert medication == %Proto.EMR.MedicationsItem{
               direction: "",
               name: "medication_1",
               medication_id: "",
               price_aed: 0,
               quantity: "",
               refills: 0
             }
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

      _bundle =
        EMR.Factory.insert(:medications_bundle,
          patient_id: patient.id,
          timeline_id: record.id,
          specialist_id: current_external.id
        )

      path = panel_emr_medications_path(conn, :history_for_record, patient.id, record.id)
      conn = get(conn, path)

      assert %Proto.EMR.GetMedicationsHistoryResponse{
               bundles: [
                 %Proto.EMR.MedicationsBundle{
                   specialist_id: specialist_id
                 }
               ]
             } = proto_response(conn, 200, Proto.EMR.GetMedicationsHistoryResponse)

      assert specialist_id == current_external.id
    end
  end
end
