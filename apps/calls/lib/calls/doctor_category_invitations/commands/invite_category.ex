defmodule Calls.DoctorCategoryInvitations.Commands.InviteCategory do
  @fields [
    :category_id,
    :call_id,
    :invited_by_specialist_id,
    :patient_id,
    :record_id,
    :session_id
  ]

  @enforce_keys @fields
  defstruct @fields
end
