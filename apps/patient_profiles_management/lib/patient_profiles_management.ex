defmodule PatientProfilesManagement do
  defdelegate add_related_child_profile(child_basic_info_params, adult_patient_id),
    to: PatientProfilesManagement.FamilyRelationship,
    as: :add_related_child_profile

  defdelegate get_related_adult_patient_id(patient_id),
    to: PatientProfilesManagement.FamilyRelationship,
    as: :get_related_adult_patient_id

  defdelegate get_related_adult_patients_map(patients_ids),
    to: PatientProfilesManagement.FamilyRelationship,
    as: :get_related_adult_patients_map

  defdelegate get_related_child_patient_ids(patient_id),
    to: PatientProfilesManagement.FamilyRelationship,
    as: :get_related_child_patient_ids

  defdelegate who_should_be_notified(patient_id),
    to: PatientProfilesManagement.FamilyRelationship,
    as: :who_should_be_notified
end
