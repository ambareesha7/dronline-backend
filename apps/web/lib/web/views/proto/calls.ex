defmodule Web.View.Calls do
  def render_patients_queue(patients_queue) do
    %Proto.Calls.PatientsQueue{
      patients_queue_entries: Enum.map(patients_queue, &patients_queue_entry/1),
      patients_queue_entries_v2: []
    }
  end

  def render_patients_queue_v2(patients_queue) do
    %Proto.Calls.PatientsQueue{
      patients_queue_entries: [],
      patients_queue_entries_v2: Enum.map(patients_queue, &patients_queue_entry_v2/1)
    }
  end

  defp patients_queue_entry(patient_queue_entry) do
    %Proto.Calls.PatientsQueueEntry{
      patient: Web.View.Generics.render_patient(patient_queue_entry.patient),
      record_id: patient_queue_entry.record_id
    }
  end

  defp patients_queue_entry_v2(patient_queue_entry) do
    basic_info = patient_queue_entry.patient.basic_info

    %Proto.Calls.PatientsQueueEntryV2{
      record_id: patient_queue_entry.record_id,
      patient_id: patient_queue_entry.patient.patient_id,
      first_name: basic_info.first_name,
      last_name: basic_info.last_name,
      avatar_url: Upload.signed_download_url(basic_info.avatar_resource_path),
      gender: Web.View.Generics.parse_gender(basic_info.gender),
      is_signed_up: patient_queue_entry.patient.account.is_signed_up
    }
  end

  def render_call_established(call_established) do
    %Proto.Calls.CallEstablished{
      api_key: call_established.api_key,
      call_id: call_established.call_id,
      patient_id: call_established.patient_id,
      record_id: call_established.record_id,
      session_id: call_established.session_id,
      token: call_established.token
    }
  end

  def render_pending_nurse_to_gp_calls(pending_calls) do
    %Proto.Calls.PendingNurseToGPCalls{
      pending_calls: Enum.map(pending_calls, &pending_nurse_to_gp_calls/1)
    }
  end

  defp pending_nurse_to_gp_calls(pending_call) do
    %Proto.Calls.PendingNurseToGPCall{
      nurse: Web.View.Generics.render_specialist(pending_call.nurse),
      record_id: pending_call.record_id,
      patient_id: pending_call.patient_id
    }
  end

  def render_doctor_category_invitations(category_id, invitations) do
    %Proto.Calls.DoctorCategoryInvitations{
      category_id: category_id,
      invitations: Enum.map(invitations, &doctor_category_invitation/1)
    }
  end

  defp doctor_category_invitation(invitation) do
    %Proto.Calls.DoctorCategoryInvitation{
      invited_by: Web.View.Generics.render_specialist(invitation.invited_by),
      call_id: invitation.call_id,
      patient_id: invitation.patient_id,
      record_id: invitation.record_id,
      sent_at: parse_timestamp(invitation.sent_at)
    }
  end

  defp parse_timestamp(timestamp), do: Timex.to_unix(timestamp)
end
