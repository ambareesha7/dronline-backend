defmodule Web.PanelApi.EMR.ProceduressControllerTest do
  use Web.ConnCase, async: true

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

      _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)

      timeline_1 = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      timeline_2 = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      condition = EMR.Factory.insert(:condition)
      procedure_1 = EMR.Factory.insert(:procedure, %{name: "procedure 1"})
      procedure_2 = EMR.Factory.insert(:procedure, %{name: "procedure 2"})

      _medical_summary_1 =
        EMR.Factory.insert(:medical_summary,
          conditions: [condition],
          procedures: [procedure_1],
          specialist_id: current_external.id,
          timeline_id: timeline_1.id
        )

      _medical_summary_2 =
        EMR.Factory.insert(:medical_summary,
          conditions: [condition],
          procedures: [procedure_1, procedure_2],
          specialist_id: current_external.id,
          timeline_id: timeline_2.id
        )

      conn = get(conn, panel_emr_procedures_path(conn, :index), limit: "1")

      assert %Proto.EMR.GetProceduresResponse{
               bundles: [
                 %Proto.EMR.ProceduresBundle{
                   patient_id: patient_id,
                   specialist_id: specialist_id,
                   procedures: [_, _],
                   inserted_at: _
                 }
               ],
               specialists: [_],
               patients: [_],
               next_token: _
             } = proto_response(conn, 200, Proto.EMR.GetProceduresResponse)

      assert patient_id == patient.id
      assert specialist_id == current_external.id
    end
  end
end
