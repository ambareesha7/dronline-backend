defmodule PatientProfilesManagement.Commands.RegisterFamilyRelationship do
  @fields [:adult_patient_id, :child_patient_id]

  @enforce_keys @fields
  defstruct @fields
end
