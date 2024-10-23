defmodule Proto.EMRView do
  use Proto.View

  def render("record.proto", %{record: record}) do
    %{
      record_id: record.timeline_id,
      start_date:
        render_one(record.start_date, Proto.GenericsView, "datetime.proto", as: :datetime),
      end_date: render_one(record.end_date, Proto.GenericsView, "datetime.proto", as: :datetime)
    }
    |> Proto.validate!(Proto.EMR.PatientRecord)
    |> Proto.EMR.PatientRecord.new()
  end

  def render("medical_summary.proto", %{medical_summary: medical_summary}) do
    %{
      inserted_at: medical_summary.inserted_at,
      medical_summary_data: medical_summary.medical_summary_data,
      specialist:
        render_one(medical_summary.specialist, __MODULE__, "specialist.proto", as: :specialist),
      is_draft: medical_summary.is_draft
    }
    |> Proto.validate!(Proto.EMR.MedicalSummary)
    |> Proto.EMR.MedicalSummary.new()
  end

  def render("specialist.proto", %{specialist: specialist}) do
    %{
      type: specialist.type |> Proto.EMR.Specialist.Type.value(),
      first_name: specialist.first_name,
      last_name: specialist.last_name,
      avatar_url: specialist.avatar_url,
      medical_categories: specialist.medical_categories,
      package_type: specialist.package_type |> Proto.EMR.Specialist.PackageType.value()
    }
    |> Proto.validate!(Proto.EMR.Specialist)
    |> Proto.EMR.Specialist.new()
  end
end
