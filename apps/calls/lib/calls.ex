defmodule Calls do
  defdelegate accept_doctor_category_invitation(cmd),
    to: Calls.DoctorCategoryInvitations.Commands,
    as: :accept_invitation

  defdelegate answer_call_from_nurse_as_gp(cmd),
    to: Calls.PendingNurseToGPCalls.Commands,
    as: :answer_call_from_nurse

  defdelegate call_gp_as_nurse(cmd),
    to: Calls.PendingNurseToGPCalls.Commands,
    as: :call_gp

  defdelegate cancel_call_to_gp_as_nurse(cmd),
    to: Calls.PendingNurseToGPCalls.Commands,
    as: :cancel_call_to_gp

  defdelegate cancel_doctor_category_invitation(cmd),
    to: Calls.DoctorCategoryInvitations.Commands,
    as: :cancel_invitation

  defdelegate fetch_hpi(patient_id),
    to: Calls.HPI.Fetch,
    as: :call

  defdelegate fetch_doctor_category_invitations(specialist_id, category_id),
    to: Calls.DoctorCategoryInvitations,
    as: :fetch_invitations

  defdelegate fetch_pending_nurse_to_gp_calls,
    to: Calls.PendingNurseToGPCalls,
    as: :fetch

  defdelegate invite_doctor_category(cmd),
    to: Calls.DoctorCategoryInvitations.Commands,
    as: :invite_doctor_category

  defdelegate register_hpi_history(patient_id, proto),
    to: Calls.HPI.RegisterHistory,
    as: :call
end
