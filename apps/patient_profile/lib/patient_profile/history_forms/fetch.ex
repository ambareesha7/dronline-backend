defmodule PatientProfile.HistoryForms.Fetch do
  alias PatientProfile.HistoryForms

  alias PatientProfile.HistoryForms.Templates

  @typep parsed_history_forms :: %{
           social: Proto.Forms.Form.t(),
           medical: Proto.Forms.Form.t(),
           surgical: Proto.Forms.Form.t(),
           family: Proto.Forms.Form.t(),
           allergy: Proto.Forms.Form.t(),
           immunization: Proto.Forms.Form.t()
         }

  @spec call(pos_integer) :: {:ok, parsed_history_forms}
  def call(patient_id) do
    {:ok, history_forms} = HistoryForms.fetch_by_patient_id(patient_id)

    {:ok, parse_history_forms(history_forms)}
  end

  defp parse_history_forms(history_forms) do
    %{
      social: parse_form(history_forms.social, :social),
      medical: parse_form(history_forms.medical, :medical),
      surgical: parse_form(history_forms.surgical, :surgical),
      family: parse_form(history_forms.family, :family),
      allergy: parse_form(history_forms.allergy, :allergy),
      immunization: parse_form(history_forms.immunization, :immunization)
    }
  end

  defp parse_form(proto, _kind) when is_binary(proto), do: Proto.Forms.Form.decode(proto)
  defp parse_form(nil, :social), do: Templates.default_social_form()
  defp parse_form(nil, :medical), do: Templates.default_medical_form()
  defp parse_form(nil, :surgical), do: Templates.default_surgical_form()
  defp parse_form(nil, :family), do: Templates.default_family_form()
  defp parse_form(nil, :allergy), do: Templates.default_allergy_form()
  defp parse_form(nil, :immunization), do: Templates.default_immunization_form()
end
