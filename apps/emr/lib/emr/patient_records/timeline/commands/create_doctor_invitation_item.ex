defmodule EMR.PatientRecords.Timeline.Commands.CreateDoctorInvitationItem do
  @fields [:medical_category_id, :patient_id, :record_id, :specialist_id]

  @enforce_keys @fields
  defstruct @fields
end
