defmodule EMR.ProceduresTest do
  use Postgres.DataCase, async: true

  alias EMR.Procedures

  describe "get_for_specialist/1" do
    test "returns list of medical summaries, with pagination" do
      patient = PatientProfile.Factory.insert(:patient)
      _address = PatientProfile.Factory.insert(:address, patient_id: patient.id)
      specialist = Authentication.Factory.insert(:verified_and_approved_external)

      EMR.register_interaction_between(specialist.id, patient.id)

      timeline_1 = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      timeline_2 = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      condition = EMR.Factory.insert(:condition)
      procedure_1 = EMR.Factory.insert(:procedure, %{name: "procedure 1"})
      procedure_2 = EMR.Factory.insert(:procedure, %{name: "procedure 2"})

      medical_summary_1 =
        EMR.Factory.insert(:medical_summary,
          conditions: [condition],
          procedures: [procedure_1],
          specialist_id: specialist.id,
          timeline_id: timeline_1.id
        )

      medical_summary_2 =
        EMR.Factory.insert(:medical_summary,
          conditions: [condition],
          procedures: [procedure_2],
          specialist_id: specialist.id,
          timeline_id: timeline_2.id
        )

      params = %{"limit" => "1"}

      assert {:ok, [medical_summary], next_token} =
               Procedures.get_for_specialist(specialist.id, params)

      assert medical_summary.inserted_at == medical_summary_2.inserted_at
      assert next_token == medical_summary_1.inserted_at

      params = %{"limit" => "1", "next_token" => Procedures.encode_next_token(next_token)}

      assert {:ok, [medical_summary], nil} = Procedures.get_for_specialist(specialist.id, params)

      assert medical_summary.inserted_at == medical_summary_1.inserted_at
    end
  end
end
