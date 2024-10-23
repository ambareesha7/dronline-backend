defmodule Calls.DoctorCategoryInvitations.Commands.CancelInvitation do
  @fields [:category_id, :call_id]

  @enforce_keys @fields
  defstruct @fields
end
