defmodule Proto.VitalsView do
  use Proto.View

  def render("vitals_entry.proto", %{vitals_entry: vitals_entry}) do
    %{
      id: vitals_entry.id,
      bmi: render_one(vitals_entry.bmi, Proto.PatientProfileView, "bmi.proto", as: :bmi),
      blood_pressure:
        render_one(vitals_entry.blood_pressure, Proto.PatientProfileView, "blood_pressure.proto",
          as: :blood_pressure
        ),
      ekg: render_one(vitals_entry.ekg, __MODULE__, "ekg.proto", as: :ekg)
    }
    |> Proto.validate!(Proto.Vitals.VitalsEntry)
    |> Proto.Vitals.VitalsEntry.new()
  end

  def render("ekg.proto", %{ekg: ekg}) do
    %{
      file_url: ekg.file_url
    }
    |> Proto.validate!(Proto.Vitals.EKG)
    |> Proto.Vitals.EKG.new()
  end
end
