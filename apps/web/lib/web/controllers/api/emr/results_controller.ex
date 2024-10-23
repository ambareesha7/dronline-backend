defmodule Web.Api.EMR.ResultsController do
  use Web, :controller

  action_fallback Web.FallbackController

  def blood_pressure_entries(conn, params) do
    patient_id = conn.assigns.current_patient_id

    %{"record_id" => record_id} = params
    record_id = String.to_integer(record_id)

    {:ok, vitals, next_token} =
      Triage.fetch_blood_pressure_entries_for_record(patient_id, record_id, params)

    conn |> render("blood_pressure_entries.proto", %{vitals: vitals, next_token: next_token})
  end

  def bmi_entries(conn, params) do
    patient_id = conn.assigns.current_patient_id

    %{"record_id" => record_id} = params
    record_id = String.to_integer(record_id)

    {:ok, vitals, next_token} = Triage.fetch_bmi_entries_for_record(patient_id, record_id, params)

    conn |> render("bmi_entries.proto", %{vitals: vitals, next_token: next_token})
  end
end

defmodule Web.Api.EMR.ResultsView do
  use Web, :view

  def render("blood_pressure_entries.proto", %{vitals: vitals, next_token: next_token}) do
    %Proto.EMR.GetRecordBloodPressureEntriesResponse{
      blood_pressure_entries: Enum.map(vitals, &render_blood_pressure_entry/1),
      next_token: next_token
    }
  end

  def render("bmi_entries.proto", %{vitals: vitals, next_token: next_token}) do
    %Proto.EMR.GetRecordBMIEntriesResponse{
      bmi_entries: Enum.map(vitals, &render_bmi_entry/1),
      next_token: next_token
    }
  end

  def render_blood_pressure_entry(vitals) do
    %Proto.EMR.GetRecordBloodPressureEntriesResponse.BloodPressureEntry{
      blood_pressure: %Proto.PatientProfile.BloodPressure{
        systolic: vitals.systolic,
        diastolic: vitals.diastolic,
        pulse: vitals.pulse
      },
      inserted_at: Timex.to_unix(vitals.inserted_at)
    }
  end

  def render_bmi_entry(vitals) do
    %Proto.EMR.GetRecordBMIEntriesResponse.BMIEntry{
      bmi: %Proto.PatientProfile.BMI{
        height: %Proto.Generics.Height{value: vitals.height},
        weight: %Proto.Generics.Weight{value: vitals.weight}
      },
      inserted_at: Timex.to_unix(vitals.inserted_at)
    }
  end
end
