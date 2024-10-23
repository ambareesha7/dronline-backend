defmodule Web.View.Vitals do
  # DEPRECATED
  def render_vitals_entry(%EMR.PatientRecords.Timeline.ItemData.Vitals{} = vitals) do
    %Proto.Vitals.VitalsEntry{
      id: vitals.id,
      bmi: %Proto.PatientProfile.BMI{
        height: vitals.height |> Web.View.Generics.render_height(),
        weight: vitals.weight |> Web.View.Generics.render_weight()
      },
      blood_pressure: %Proto.PatientProfile.BloodPressure{
        systolic: vitals.systolic,
        diastolic: vitals.diastolic,
        pulse: vitals.pulse
      },
      ekg: %Proto.Vitals.EKG{
        file_url: vitals.ekg_file_url
      }
    }
  end

  def render_vitals_entry(%Triage.Vitals{} = vitals) do
    %Proto.Vitals.VitalsEntry{
      id: vitals.id,
      bmi: %Proto.PatientProfile.BMI{
        height: vitals.height |> Web.View.Generics.render_height(),
        weight: vitals.weight |> Web.View.Generics.render_weight()
      },
      blood_pressure: %Proto.PatientProfile.BloodPressure{
        systolic: vitals.systolic,
        diastolic: vitals.diastolic,
        pulse: vitals.pulse
      },
      ekg: %Proto.Vitals.EKG{
        file_url: vitals.ekg_file_url
      }
    }
  end
end
