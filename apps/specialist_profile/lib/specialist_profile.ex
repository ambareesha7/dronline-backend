defmodule SpecialistProfile do
  defdelegate fetch_basic_info(specialist_id, opts \\ nil),
    to: SpecialistProfile.BasicInfo,
    as: :fetch_by_specialist_id

  defdelegate fetch_basic_infos(specialist_ids),
    to: SpecialistProfile.BasicInfo,
    as: :fetch_by_specialist_ids

  defdelegate fetch_location(specialist_id),
    to: SpecialistProfile.Location,
    as: :fetch_by_specialist_id

  defdelegate fetch_locations(specialist_id),
    to: SpecialistProfile.Location,
    as: :fetch_by_specialist_ids

  defdelegate fetch_medical_categories(specialist_id),
    to: SpecialistProfile.MedicalCategories.MedicalCategory,
    as: :fetch_for_doctor

  defdelegate fetch_medical_credentials(specialist_id_or_ids),
    to: SpecialistProfile.MedicalCredentials.Fetch,
    as: :call

  defdelegate fetch_specialists(params),
    to: SpecialistProfile.Specialists,
    as: :fetch_all

  defdelegate fetch_online_specialists(params, online_ids),
    to: SpecialistProfile.Specialists,
    as: :fetch_online

  defdelegate fetch_status(specialist_id),
    to: SpecialistProfile.Status,
    as: :fetch_by_specialist_id

  defdelegate fetch_prices(specialist_id),
    to: SpecialistProfile.Prices,
    as: :fetch_by_specialist_id

  defdelegate fetch_specialists_prices(specialists_id),
    to: SpecialistProfile.Prices,
    as: :fetch_by_specialists_id

  defdelegate fetch_insurances(specialists_id),
    to: SpecialistProfile.Insurances.Provider,
    as: :fetch_by_specialist_id

  defdelegate fetch_by_ids_with_insurance_providers(specialists_ids),
    to: SpecialistProfile.Specialist,
    as: :fetch_by_ids_with_insurance_providers

  defdelegate get_bio(specialist_id),
    to: SpecialistProfile.Bio,
    as: :get_by_specialist_id

  defdelegate get_bios(specialist_ids),
    to: SpecialistProfile.Bio,
    as: :get_by_specialist_ids

  defdelegate get_medical_categories_for_specialists(specialist_ids),
    to: SpecialistProfile.MedicalCategories.MedicalCategory,
    as: :get_medical_categories_for_specialists

  defdelegate get_specialist_ids_for_medical_category(medical_category_id),
    to: SpecialistProfile.MedicalCategories.MedicalCategory,
    as: :get_specialist_ids_for_medical_category

  defdelegate update_basic_info(params, specialist_id),
    to: SpecialistProfile.BasicInfo,
    as: :update

  defdelegate update_bio(specialist_id, params),
    to: SpecialistProfile.Bio,
    as: :update

  defdelegate update_location(params, specialist_id),
    to: SpecialistProfile.Location,
    as: :update

  defdelegate update_medical_categories(categories_ids, specialist_id),
    to: SpecialistProfile.Specialist,
    as: :update_categories

  defdelegate update_medical_credentials(params, specialist_id),
    to: SpecialistProfile.MedicalCredentials,
    as: :update

  defdelegate update_medical_info(specialist_id, medical_categories, medical_credentials),
    to: SpecialistProfile.UpdateMedicalInfo,
    as: :call

  defdelegate update_prices(specialist_id, params),
    to: SpecialistProfile.Prices,
    as: :update

  defdelegate update_insurance_providers(specialist_id, providers_ids),
    to: SpecialistProfile.Specialist,
    as: :update_insurance_providers

  defdelegate search(params),
    to: SpecialistProfile.Specialists,
    as: :search
end
