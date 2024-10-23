defmodule Calls.DoctorCategoryInvitations.Commands.AcceptInvitation do
  @fields [:category_id, :call_id, :doctor_id]

  @enforce_keys @fields
  defstruct @fields
end
