defmodule EMR do
  defdelegate assign_tokbox_session_to_record(record_id, tokbox_session_id),
    to: EMR.PatientRecords.VideoRecordings.TokboxSession,
    as: :assign_tokbox_session_to_record

  defdelegate add_newest_vitals(patient_id, record_id, nurse_id, params),
    to: EMR.PatientRecords.Vitals,
    as: :add_newest

  defdelegate create_ordered_tests_bundle(patient_id, record_id, specialist_id, params),
    to: EMR.PatientRecords.OrderedTestsBundle,
    as: :create

  defdelegate create_medications_bundle(patient_id, record_id, specialist_id, params),
    to: EMR.PatientRecords.MedicationsBundle,
    as: :create

  defdelegate fetch_by_bundle_id(bundle_id),
    to: EMR.PatientRecords.MedicationsBundle,
    as: :fetch_by_bundle_id

  defdelegate close_patient_record(patient_id, record_id),
    to: EMR.PatientRecords.PatientRecord,
    as: :close

  defdelegate create_call_timeline_item(cmd),
    to: EMR.PatientRecords.Timeline.Item,
    as: :create_call_item

  defdelegate create_call_recording_timeline_item(cmd),
    to: EMR.PatientRecords.Timeline.Item,
    as: :create_call_recording_item

  defdelegate create_dispatch_request_item(cmd),
    to: EMR.PatientRecords.Timeline.Item,
    as: :create_dispatch_request_item

  defdelegate create_doctor_invitation_timeline_item(cmd),
    to: EMR.PatientRecords.Timeline.Item,
    as: :create_doctor_invitation_item

  defdelegate create_invitation(specialist_id, invitation_proto),
    to: EMR.PatientInvitations.Create,
    as: :call

  defdelegate create_medical_summary(specialist_id, record_id, summary_data, request_uuid),
    to: EMR.PatientRecords.MedicalSummary,
    as: :create

  defdelegate create_medical_summary_draft(specialist_id, record_id, summary_data),
    to: EMR.PatientRecords.MedicalSummary,
    as: :create_draft

  defdelegate get_medical_summary_draft(specialist_id, record_id),
    to: EMR.PatientRecords.MedicalSummary,
    as: :fetch_draft

  defdelegate remove_medical_summary_draft(specialist_id, record_id),
    to: EMR.PatientRecords.MedicalSummary,
    as: :remove_draft

  defdelegate create_manual_patient_record(patient_id, created_by_specialist_id),
    to: EMR.PatientRecords.PatientRecord,
    as: :create_manual_record

  defdelegate create_timeline_item_comment(cmd),
    to: EMR.PatientRecords.Timeline.Item.Comment,
    as: :create

  defdelegate create_visit_patient_record(patient_id, with_specialist_id),
    to: EMR.PatientRecords.PatientRecord,
    as: :create_visit_record

  defdelegate create_in_office_patient_record(patient_id, with_specialist_id),
    to: EMR.PatientRecords.PatientRecord,
    as: :create_in_office_record

  defdelegate create_us_board_patient_record(patient_id, with_specialist_id, us_board_request_id),
    to: EMR.PatientRecords.PatientRecord,
    as: :create_us_board_record

  defdelegate create_call_type_patient_record(patient_id, specialist_id, call_session_id),
    to: EMR.PatientRecords.CallTypePatientRecord,
    as: :create

  defdelegate fetch_or_create_automatic_record(patient_id),
    to: EMR.PatientRecords.PatientRecord,
    as: :fetch_or_create_automatic

  defdelegate fetch_call_recordings_for_record(patient_id, record_id, params),
    to: EMR.PatientRecords.Timeline.ItemData.CallRecording,
    as: :fetch_for_record

  defdelegate fetch_connected_patients_list(specialist_id, params),
    to: EMR.PatientsList,
    as: :fetch_connected

  defdelegate fetch_hpi(patient_id, timeline_id, kind \\ :default),
    to: EMR.HPI,
    as: :fetch_last_for_timeline_id

  defdelegate fetch_hpi_history(timeline_id),
    to: EMR.HPI,
    as: :fetch_history_for_timeline_id

  defdelegate fetch_medical_summaries(record_id),
    to: EMR.PatientRecords.MedicalSummary,
    as: :fetch

  defdelegate fetch_medical_summary(medical_summary_id),
    to: EMR.PatientRecords.MedicalSummary,
    as: :fetch_by_id

  defdelegate fetch_latest_summary_for_specialist(specialist_id, record_id),
    to: EMR.PatientRecords.MedicalSummary,
    as: :fetch_latest_for_specialist

  defdelegate fetch_patient_records(patient_id, params),
    to: EMR.PatientRecords.PatientRecord,
    as: :fetch

  defdelegate fetch_patient_record(record_id, patient_id),
    to: EMR.PatientRecords.PatientRecord,
    as: :fetch_by_id

  defdelegate fetch_patient_specialists_ids(patient_id),
    to: EMR.SpecialistPatientConnections.SpecialistPatientConnection,
    as: :fetch_patient_specialists_ids

  defdelegate fetch_patients_list(team_id, params),
    to: EMR.PatientsList,
    as: :fetch

  defdelegate fetch_timeline_for_record(record_id),
    to: EMR.PatientRecords.Timeline,
    as: :fetch_by_id

  defdelegate fetch_timeline_item_comments(patient_id, record_id, timeline_item_id, params),
    to: EMR.PatientRecords.Timeline.Item.Comment,
    as: :fetch_paginated

  defdelegate fetch_vitals_history(patient_id, params),
    to: EMR.PatientRecords.Vitals,
    as: :fetch_history

  defdelegate fetch_vitals_history_for_record(patient_id, record_id, params),
    to: EMR.PatientRecords.Vitals,
    as: :fetch_history_for_record

  defdelegate fetch_ordered_tests_bundle(bundle_id),
    to: EMR.PatientRecords.OrderedTestsBundle,
    as: :fetch_by_id

  defdelegate fetch_ordered_tests_history_for_record(record_id),
    to: EMR.PatientRecords.OrderedTestsBundle,
    as: :fetch_history_for_record

  defdelegate fetch_medications_bundle(bundle_id),
    to: EMR.PatientRecords.MedicationsBundle,
    as: :fetch_by_id

  defdelegate fetch_medications_history_for_record(record_id),
    to: EMR.PatientRecords.MedicationsBundle,
    as: :fetch_history_for_record

  defdelegate fetch_conditions(query),
    to: EMR.PatientRecords.MedicalLibrary.Condition,
    as: :fetch

  defdelegate fetch_procedures(query),
    to: EMR.PatientRecords.MedicalLibrary.Procedure,
    as: :fetch

  defdelegate fetch_medications(query),
    to: EMR.PatientRecords.MedicalLibrary.Medication,
    as: :fetch

  defdelegate fetch_tests_by_categories(),
    to: EMR.PatientRecords.MedicalLibrary.Test,
    as: :fetch_by_categories

  defdelegate generate_record_pdf_for_patient(record_id, token),
    to: EMR.PatientRecords.RecordPDF,
    as: :generate_for_patient

  defdelegate generate_record_pdf_for_specialist(patient_id, record_id, token),
    to: EMR.PatientRecords.RecordPDF,
    as: :generate_for_specialist

  defdelegate get_display_name_for_timeline_item(timeline_item),
    to: EMR.PatientRecords.Timeline.Item.DisplayName,
    as: :get_for

  defdelegate get_latest_vitals(patient_id),
    to: EMR.PatientRecords.Vitals,
    as: :get_latest

  defdelegate get_pending_medical_summary(specialist_id),
    to: EMR.PatientRecords.MedicalSummary.PendingSummary,
    as: :get_by_specialist_id

  defdelegate get_record_main_specialist_ids(record),
    to: EMR.PatientRecords.PatientRecord,
    as: :get_main_specialist_ids

  defdelegate get_timeline_item(timeline_item_id),
    to: EMR.PatientRecords.Timeline.Item,
    as: :get

  defdelegate process_video_recording_and_add_to_record(archive_id, session_id, archive_info),
    to: EMR.PatientRecords.VideoRecordings,
    as: :process_video_recording_and_add_to_record

  defdelegate register_hpi_history(patient_id, timeline_id, proto),
    to: EMR.HPI,
    as: :register_history

  defdelegate register_interaction_between(specialist_id, patient_id),
    to: EMR.SpecialistPatientConnections.SpecialistPatientConnection,
    as: :create

  defdelegate resolve_pending_medical_summary(record_id, specialist_id),
    to: EMR.PatientRecords.MedicalSummary.PendingSummary,
    as: :resolve

  defdelegate set_with_whom_value_for_record(patient_id, record_id, with_specialist_id),
    to: EMR.PatientRecords.PatientRecord,
    as: :set_with_whom_value

  defdelegate specialist_connected_with_patient?(specialist_id, patient_id),
    to: EMR.SpecialistPatientConnections.SpecialistPatientConnection,
    as: :specialist_patient_connected?

  defdelegate specialist_ids_in_timeline_item(timeline_item),
    to: EMR.PatientRecords.Timeline.Item,
    as: :specialist_ids_in_item

  defdelegate specialist_patient_connected?(specialist_id, id_param, via_timeline),
    to: EMR.SpecialistPatientConnections.SpecialistPatientConnection,
    as: :specialist_patient_connected?
end
