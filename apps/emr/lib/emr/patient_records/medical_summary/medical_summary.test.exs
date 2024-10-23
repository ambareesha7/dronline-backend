defmodule EMR.PatientRecords.MedicalSummaryTest do
  use Postgres.DataCase, async: true

  alias EMR.PatientRecords.MedicalLibrary.Condition
  alias EMR.PatientRecords.MedicalLibrary.Procedure
  alias EMR.PatientRecords.MedicalSummary

  describe "create/3" do
    test "Fails if procedures or conditions not provided" do
      specialist = Authentication.Factory.insert(:specialist)
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      request_data = %{
        conditions: [],
        procedures: [],
        medical_summary_data:
          Proto.EMR.MedicalSummaryData.new(interview_summary: "interview_summary")
      }

      assert {
               :error,
               %Ecto.Changeset{
                 valid?: false,
                 errors: [
                   procedures: {
                     "should have at least %{count} item(s)",
                     [count: 1, validation: :length, kind: :min, type: :list]
                   },
                   conditions: {
                     "should have at least %{count} item(s)",
                     [count: 1, validation: :length, kind: :min, type: :list]
                   }
                 ]
               }
             } =
               MedicalSummary.create(
                 specialist.id,
                 timeline.id,
                 request_data,
                 UUID.uuid4()
               )
    end

    test "creates new medical_summary" do
      specialist = Authentication.Factory.insert(:specialist)
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      condition = EMR.Factory.insert(:condition)
      procedure = EMR.Factory.insert(:procedure)

      request_data =
        Proto.EMR.AddMedicalSummaryRequest.new(
          conditions: [condition.id],
          procedures: [procedure.id],
          medical_summary_data:
            Proto.EMR.MedicalSummaryData.new(interview_summary: "interview_summary")
        )

      assert {:ok, %MedicalSummary{}} =
               MedicalSummary.create(specialist.id, timeline.id, request_data, UUID.uuid4())
    end

    test "second request with the same request_uuid overrides the first one" do
      specialist = Authentication.Factory.insert(:specialist)
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      condition = EMR.Factory.insert(:condition)
      procedure = EMR.Factory.insert(:procedure)

      condition2 = EMR.Factory.insert(:condition)
      procedure2 = EMR.Factory.insert(:procedure)

      request_data = %{
        conditions: [condition.id],
        procedures: [procedure.id],
        medical_summary_data:
          Proto.EMR.MedicalSummaryData.new(interview_summary: "interview_summary")
      }

      request_uuid = UUID.uuid4()

      assert {:ok, %MedicalSummary{}} =
               MedicalSummary.create(specialist.id, timeline.id, request_data, request_uuid)

      update_request_data = %{
        conditions: [condition2.id],
        procedures: [procedure2.id],
        medical_summary_data: Proto.EMR.MedicalSummaryData.new(interview_summary: "updated")
      }

      {:ok, medical_summary} =
        MedicalSummary.create(specialist.id, timeline.id, update_request_data, request_uuid)

      assert %{
               id: _,
               data: data,
               conditions: [%Condition{id: condition_id}],
               procedures: [%Procedure{id: procedure_id}]
             } = medical_summary

      assert condition_id == condition2.id
      assert procedure_id == procedure2.id

      assert %{
               interview_summary: "updated"
             } = Proto.EMR.MedicalSummaryData.decode(data)
    end

    test "second request sets edited_at for any existing summary with same timeline_id" do
      specialist = Authentication.Factory.insert(:specialist)
      patient = PatientProfile.Factory.insert(:patient)

      timeline_1 =
        EMR.Factory.insert(:visit_record, patient_id: patient.id, specialist_id: specialist.id)

      timeline_2 =
        EMR.Factory.insert(:visit_record, patient_id: patient.id, specialist_id: specialist.id)

      condition = EMR.Factory.insert(:condition)
      procedure = EMR.Factory.insert(:procedure)

      request_data_1 = %{
        conditions: [condition.id],
        procedures: [procedure.id],
        medical_summary_data:
          Proto.EMR.MedicalSummaryData.new(interview_summary: "interview_summary 1")
      }

      assert {:ok, medical_summary_1 = %{edited_at: nil}} =
               MedicalSummary.create(specialist.id, timeline_1.id, request_data_1, UUID.uuid4())

      request_data_2 = %{
        conditions: [condition.id],
        procedures: [procedure.id],
        medical_summary_data:
          Proto.EMR.MedicalSummaryData.new(interview_summary: "interview_summary 2")
      }

      {:ok, medical_summary_2} =
        MedicalSummary.create(specialist.id, timeline_2.id, request_data_2, UUID.uuid4())

      request_data_3 = %{
        conditions: [condition.id],
        procedures: [procedure.id],
        medical_summary_data:
          Proto.EMR.MedicalSummaryData.new(interview_summary: "interview_summary 3")
      }

      {:ok, medical_summary_3} =
        MedicalSummary.create(specialist.id, timeline_1.id, request_data_3, UUID.uuid4())

      assert %{edited_at: %NaiveDateTime{}} =
               Repo.get_by(MedicalSummary, id: medical_summary_1.id)

      assert %{edited_at: nil} = Repo.get_by(MedicalSummary, id: medical_summary_2.id)

      assert %{edited_at: nil} = Repo.get_by(MedicalSummary, id: medical_summary_3.id)
    end
  end

  describe "fetch/1" do
    test "returns newest medical summary at the beginning" do
      specialist = Authentication.Factory.insert(:specialist)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      condition = EMR.Factory.insert(:condition)
      procedure = EMR.Factory.insert(:procedure)

      summary_data = Proto.EMR.MedicalSummaryData.new(interview_summary: "interview_summary")

      request_data = %{
        conditions: [condition.id],
        procedures: [procedure.id],
        medical_summary_data: summary_data
      }

      MedicalSummary.create(specialist.id, timeline.id, request_data, UUID.uuid4())

      summary_data2 = Proto.EMR.MedicalSummaryData.new(interview_summary: "interview_summary_2")

      request_data2 = %{
        conditions: [condition.id],
        procedures: [procedure.id],
        medical_summary_data: summary_data2
      }

      MedicalSummary.create(specialist.id, timeline.id, request_data2, UUID.uuid4())

      assert {:ok, [medical_summary, medical_summary2]} = MedicalSummary.fetch(timeline.id)

      # SEE THIS
      assert Proto.EMR.MedicalSummaryData.decode(medical_summary.data) == summary_data2
      assert Proto.EMR.MedicalSummaryData.decode(medical_summary2.data) == summary_data

      assert medical_summary.is_draft == false
    end
  end

  describe "fetch_draft/2" do
    test "returns newest medical summary draft or nil" do
      specialist = Authentication.Factory.insert(:specialist)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      request_data = %{
        conditions: [],
        procedures: [],
        medical_summary_data: Proto.EMR.MedicalSummaryData.new()
      }

      {:ok, summary_draft_1} =
        MedicalSummary.create_draft(specialist.id, timeline.id, request_data)

      summary_data2 = Proto.EMR.MedicalSummaryData.new(interview_summary: "interview_summary_2")

      request_data2 = %{
        conditions: [],
        procedures: [],
        medical_summary_data: summary_data2
      }

      {:ok, _summary_draft_2} =
        MedicalSummary.create_draft(specialist.id, timeline.id, request_data2)

      assert %MedicalSummary{
               is_draft: true,
               data: data,
               id: result_summary_id,
               conditions: [],
               procedures: []
             } = MedicalSummary.fetch_draft(specialist.id, timeline.id)

      assert Proto.EMR.MedicalSummaryData.decode(data) == summary_data2
      assert result_summary_id == summary_draft_1.id

      refute MedicalSummary.fetch_draft(101, timeline.id)
    end
  end

  describe "fetch_latest_for_specialist/2" do
    test "returns latest summary or nil" do
      specialist = Authentication.Factory.insert(:specialist)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      condition_1 = EMR.Factory.insert(:condition, %{id: "1", name: "condition 1"})
      condition_2 = EMR.Factory.insert(:condition, %{id: "2", name: "condition 2"})
      procedure = EMR.Factory.insert(:procedure)

      summary_data = Proto.EMR.MedicalSummaryData.new(interview_summary: "interview_summary")

      request_data = %{
        conditions: [condition_1.id, condition_2.id],
        procedures: [procedure.id],
        medical_summary_data: summary_data
      }

      {:ok, _medical_summary_1} =
        MedicalSummary.create(specialist.id, timeline.id, request_data, UUID.uuid4())

      {:ok, medical_summary_2} =
        MedicalSummary.create(specialist.id, timeline.id, request_data, UUID.uuid4())

      assert %MedicalSummary{
               id: result_summary_id,
               conditions: [_, _]
             } = MedicalSummary.fetch_latest_for_specialist(specialist.id, timeline.id)

      assert result_summary_id == medical_summary_2.id
    end
  end
end
