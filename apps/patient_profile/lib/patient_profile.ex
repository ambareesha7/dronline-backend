defmodule PatientProfile do
  defdelegate create_new_patient_profile(phone_number),
    to: PatientProfile.Schema,
    as: :create

  defdelegate fetch_basic_info(patient_id),
    to: PatientProfile.BasicInfo,
    as: :fetch_by_patient_id

  defdelegate fetch_basic_infos(patient_ids),
    to: PatientProfile.BasicInfo,
    as: :fetch_by_patient_ids

  defdelegate fetch_basic_info_by_email(email),
    to: PatientProfile.BasicInfo,
    as: :fetch_by_email

  defdelegate fetch_bmi(patient_id),
    to: PatientProfile.BMI,
    as: :fetch_by_patient_id

  defdelegate fetch_insurance(patient_id),
    to: Insurance,
    as: :fetch_by_patient_id

  defdelegate fetch_by_id(patient_id),
    to: PatientProfile.Schema,
    as: :fetch_by_id

  #  TODO:- not used this func
  defdelegate get_patient_details(patient_id),
    to: PatientProfile.Schema,
    as: :get_patient_details

  defdelegate fetch_history_forms(patient_id),
    to: PatientProfile.HistoryForms.Fetch,
    as: :call

  defdelegate fetch_review_of_system_history(patient_id, params),
    to: PatientProfile.ReviewOfSystem,
    as: :fetch_paginated

  defdelegate fetch_status(patient_id),
    to: PatientProfile.Status,
    as: :fetch_by_patient_id

  defdelegate get_address(patient_id),
    to: PatientProfile.Address,
    as: :get_by_patient_id

  defdelegate get_latest_review_of_system(patient_id),
    to: PatientProfile.ReviewOfSystem,
    as: :get_latest

  defdelegate get_profiles(patient_ids),
    to: PatientProfile.Schema,
    as: :get_by_ids

  defdelegate register_review_of_system_change(
                patient_id,
                forms_proto,
                provided_by_specialist_id \\ nil
              ),
              to: PatientProfile.ReviewOfSystem,
              as: :register_change

  defdelegate update_all_history_forms(forms_proto, patient_id),
    to: PatientProfile.HistoryForms.UpdateAll,
    as: :call

  defdelegate update_address(params, patient_id),
    to: PatientProfile.Address.Update,
    as: :call

  defdelegate update_basic_info(params, patient_id),
    to: PatientProfile.BasicInfo,
    as: :update

  defdelegate update_bmi(params, patient_id),
    to: PatientProfile.BMI,
    as: :update

  defdelegate update_insurance(params, patient_id),
    to: Insurance,
    as: :set_patient_insurance

  defdelegate update_history_forms(forms_proto, patient_id),
    to: PatientProfile.HistoryForms.Update,
    as: :call
end
