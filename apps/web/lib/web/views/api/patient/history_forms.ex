defmodule Web.Api.Patient.HistoryFormsView do
  use Web, :view

  def render("show.proto", %{history_forms: history_forms}) do
    %{
      social: history_forms.social,
      medical: history_forms.medical,
      surgical: history_forms.surgical,
      family: history_forms.family,
      allergy: history_forms.allergy,
      immunization: history_forms.immunization
    }
    |> Proto.validate!(Proto.PatientProfile.GetHistoryResponse)
    |> Proto.PatientProfile.GetHistoryResponse.new()
  end

  def render("update.proto", %{history_forms: history_forms}) do
    %{
      social: history_forms.social,
      medical: history_forms.medical,
      surgical: history_forms.surgical,
      family: history_forms.family,
      allergy: history_forms.allergy,
      immunization: history_forms.immunization
    }
    |> Proto.validate!(Proto.PatientProfile.UpdateHistoryResponse)
    |> Proto.PatientProfile.UpdateHistoryResponse.new()
  end
end
