defmodule Triage do
  defdelegate determine_region(address),
    to: Triage.Regions,
    as: :determine_region

  defdelegate end_dispatch(cmd),
    to: Triage.Commands,
    as: :end_dispatch

  defdelegate fetch_current_dispatches,
    to: Triage.CurrentDispatch,
    as: :fetch_all

  defdelegate fetch_dispatch_by_request_id(request_id),
    to: Triage.Dispatch,
    as: :fetch_by_request_id

  defdelegate fetch_ended_dispatches(params),
    to: Triage.EndedDispatch,
    as: :fetch

  defdelegate fetch_ongoing_dispatch_for_nurse(nurse_id),
    to: Triage.OngoingDispatch,
    as: :fetch_by_nurse_id

  defdelegate fetch_pending_dispatches,
    to: Triage.PendingDispatch,
    as: :fetch_all

  defdelegate get_ended_dispatches_total_count,
    to: Triage.EndedDispatch,
    as: :get_total_count

  defdelegate request_dispatch_to_patient(cmd),
    to: Triage.Commands,
    as: :request_dispatch_to_patient

  defdelegate take_pending_dispatch(cmd),
    to: Triage.Commands,
    as: :take_pending_dispatch

  # functions below should be moved to another app
  defdelegate fetch_blood_pressure_entries_for_record(patient_id, record_id, params),
    to: Triage.Vitals,
    as: :fetch_blood_pressure_entries_for_record

  defdelegate fetch_bmi_entries_for_record(patient_id, record_id, params),
    to: Triage.Vitals,
    as: :fetch_bmi_entries_for_record
end
