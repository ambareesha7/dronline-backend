defmodule Insurance do
  defdelegate get_providers_for_country(country_code),
    to: Insurance.Providers,
    as: :all_for_country

  defdelegate set_patient_insurance(params, patient_id),
    to: Insurance.Accounts,
    as: :set

  defdelegate fetch_by_patient_id(patient_id),
    to: Insurance.Accounts,
    as: :get_for_patient

  defdelegate remove_patient_insurance(patient_id),
    to: Insurance.Accounts,
    as: :remove_for_patient
end
