defmodule EMR.Factory do
  use Postgres.Service

  def insert(kind, params \\ %{})

  def insert(:hpi, params) do
    default_params = %{form: valid_hpi_form()}
    params = Map.merge(default_params, Enum.into(params, %{}))

    {:ok, hpi} =
      EMR.register_hpi_history(params[:patient_id], params[:timeline_id], params[:form])

    hpi
  end

  def insert(:call_recording, params) do
    default_params = %EMR.PatientRecords.Timeline.Commands.CreateCallRecordingItem{
      patient_id: nil,
      record_id: nil,
      session_id: "fake_session_id",
      thumbnail_gcs_path: "fake_thumbnail_gcs_path",
      video_s3_path: "fake_thumbnail_gcs_path",
      created_at: nil,
      duration: nil
    }

    params = Map.merge(default_params, Enum.into(params, %{}))

    {:ok, record} = EMR.PatientRecords.Timeline.ItemData.CallRecording.create(params)

    record
  end

  def insert(:manual_record, params) do
    default_params = %{created_by_specialist_id: Authentication.Factory.insert(:specialist).id}
    params = Map.merge(default_params, Enum.into(params, %{}))

    {:ok, record} =
      EMR.PatientRecords.PatientRecord.create_manual_record(
        params[:patient_id],
        params[:created_by_specialist_id]
      )

    record
  end

  def insert(:automatic_record, params) do
    params = Enum.into(params, %{})

    {:ok, record} =
      EMR.PatientRecords.PatientRecord.fetch_or_create_automatic(params[:patient_id])

    record
  end

  def insert(:call_record, params) do
    params = Enum.into(params, %{})

    {:ok, record} =
      EMR.PatientRecords.CallTypePatientRecord.create(
        params[:patient_id],
        params[:specialist_id],
        params[:call_session_id]
      )

    record
  end

  def insert(:visit_record, params) do
    params = Enum.into(params, %{})

    {:ok, record} =
      EMR.PatientRecords.PatientRecord.create_visit_record(
        params[:patient_id],
        params[:specialist_id]
      )

    record
  end

  def insert(:us_board_record, params) do
    params = Enum.into(params, %{})

    {:ok, record} =
      EMR.PatientRecords.PatientRecord.create_us_board_record(
        params[:patient_id],
        params[:specialist_id],
        params[:us_board_request_id]
      )

    record
  end

  def insert(:active_record, params) do
    Repo.insert!(%EMR.PatientRecords.PatientRecord{
      shared_record_params(params)
      | active: true,
        closed_at: nil
    })
  end

  def insert(:completed_record, params) do
    Repo.insert!(%EMR.PatientRecords.PatientRecord{
      shared_record_params(params)
      | active: false,
        closed_at: NaiveDateTime.utc_now()
    })
  end

  def insert(:canceled_record, params) do
    Repo.insert!(%EMR.PatientRecords.PatientRecord{
      shared_record_params(params)
      | active: false,
        canceled_at: NaiveDateTime.utc_now()
    })
  end

  def insert(:patient_invitation, params) do
    params = Enum.into(params, %{})

    {:ok, patient_invitation} =
      EMR.PatientInvitations.PatientInvitation.create(params[:specialist_id], params)

    patient_invitation
  end

  def insert(:vitals, params) do
    default_params = %{
      height: 180,
      weight: 80,
      blood_pressure_systolic: 100,
      blood_pressure_diastolic: 70,
      pulse: 80,
      respiratory_rate: 200,
      body_temperature: 36.6,
      physical_exam: "test"
    }

    params = Map.merge(default_params, Enum.into(params, %{}))

    {:ok, vitals} =
      EMR.PatientRecords.Vitals.add_newest(
        params[:patient_id],
        params[:record_id],
        params[:nurse_id],
        params
      )

    vitals
  end

  def insert(:medical_summary, params) do
    default_params = %{
      request_uuid: UUID.uuid4(),
      specialist_id: 1,
      data:
        Proto.EMR.MedicalSummaryData.encode(%Proto.EMR.MedicalSummaryData{
          diagnosis_category: random_string(),
          cpt_code: random_string(),
          plan: random_string(),
          impression: random_string(),
          diagnostic_testing: random_string(),
          interview_summary: random_string()
        })
    }

    params = Map.merge(default_params, Enum.into(params, %{}))

    medical_summary =
      EMR.PatientRecords.MedicalSummary
      |> struct(params)
      |> Postgres.Repo.insert!()

    medical_summary
  end

  def insert(:condition, params) do
    default_params = %{
      id: random_string(),
      name: random_string()
    }

    params = Map.merge(default_params, params)

    condition =
      EMR.PatientRecords.MedicalLibrary.Condition
      |> struct(params)
      |> Postgres.Repo.insert!()

    condition
  end

  def insert(:procedure, params) do
    default_params = %{
      id: random_string(),
      name: random_string()
    }

    params = Map.merge(default_params, params)

    procedure =
      EMR.PatientRecords.MedicalLibrary.Procedure
      |> struct(params)
      |> Postgres.Repo.insert!()

    procedure
  end

  def insert(:medication, params) do
    default_params = %{
      name: "medication_name"
    }

    params = Map.merge(default_params, params)

    medication =
      EMR.PatientRecords.MedicalLibrary.Medication
      |> struct(params)
      |> Postgres.Repo.insert!()

    medication
  end

  def insert(:tests_category, params) do
    default_params = %{
      name: "tests_category_name"
    }

    params = Map.merge(default_params, params)

    tests_category =
      EMR.PatientRecords.MedicalLibrary.TestsCategory
      |> struct(params)
      |> Postgres.Repo.insert!()

    tests_category
  end

  def insert(:test, params) do
    default_params = %{
      name: "test_name"
    }

    params = Map.merge(default_params, params)

    test =
      EMR.PatientRecords.MedicalLibrary.Test
      |> struct(params)
      |> Postgres.Repo.insert!()

    test
  end

  def insert(:ordered_test, params) do
    test =
      EMR.PatientRecords.OrderedTest
      |> struct(params)
      |> Postgres.Repo.insert!()

    test
  end

  def insert(:ordered_tests_bundle, params) do
    test =
      EMR.PatientRecords.OrderedTestsBundle
      |> struct(params)
      |> Postgres.Repo.insert!()

    test
  end

  def insert(:medications_bundle, params) do
    test =
      EMR.PatientRecords.MedicationsBundle
      |> struct(params)
      |> Postgres.Repo.insert!()

    test
  end
  def insert(:medication_order, params) do
    test =
      EMR.Medications.MedicationOrder
      |> struct(params)
      |> Postgres.Repo.insert!()

    test
  end

  def insert(:medications_bundle_payment, params) do
    test =
      EMR.Medications.Payment
      |> struct(params)
      |> Postgres.Repo.insert!()

    test
  end

  defp shared_record_params(params) do
    params = Enum.into(params, %{})

    %EMR.PatientRecords.PatientRecord{
      with_specialist_id: params[:specialist_id],
      created_by_specialist_id: params[:specialist_id],
      patient_id: params.patient_id,
      type: Map.get(params, :type, :VISIT),
      inserted_at: Map.get(params, :inserted_at, NaiveDateTime.utc_now()),
      insurance_account_id: params[:insurance_account_id],
      us_board_request_id: params[:us_board_request_id]
    }
  end

  def valid_hpi_form do
    template = EMR.HPI.Template.template(:default)

    %{template | fields: Enum.map(template.fields, &add_answer/1), completed: true}
  end

  defp add_answer(%{value: {:select, select}} = field) do
    %{
      field
      | value: {:select, %{select | choice: Enum.random(select.options)}}
    }
  end

  defp add_answer(%{value: {:string, string}} = field) do
    %{
      field
      | value: {:string, %{string | value: random_string(), is_set: true}}
    }
  end

  defp random_string do
    System.unique_integer() |> to_string()
  end
end
