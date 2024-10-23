defmodule Admin do
  defdelegate create_internal_specialist(params),
    to: Admin.InternalSpecialists.Create,
    as: :call

  defdelegate add_specialist_to_team(params),
    to: Admin.InternalSpecialists.InviteToTeam,
    as: :call

  defdelegate fetch_external_specialist(params),
    to: Admin.ExternalSpecialists.ExternalSpecialist,
    as: :fetch_by_id

  defdelegate fetch_external_specialists(params),
    to: Admin.ExternalSpecialists.ExternalSpecialist,
    as: :fetch

  defdelegate fetch_internal_specialist(id),
    to: Admin.InternalSpecialists.InternalSpecialist,
    as: :fetch_by_id

  defdelegate fetch_internal_specialists(params),
    to: Admin.InternalSpecialists.InternalSpecialist,
    as: :fetch_all

  defdelegate subscribe_to_newsletter(email, phone_number),
    to: Admin.Newsletter.Subscriber,
    as: :create

  defdelegate verify_external_specialist(specialist_id, status),
    to: Admin.ExternalSpecialists.SetApprovalStatus,
    as: :call

  defdelegate fetch_new_medications(query),
    to: Admin.Medications,
    as: :fetch

  defdelegate fetch_medication_by_id(id),
    to: Admin.Medications.MedicalMedications,
    as: :get_by_id

  defdelegate fetch_medication_by_name(name),
    to: Admin.Medications.MedicalMedications,
    as: :get_by_name
end
