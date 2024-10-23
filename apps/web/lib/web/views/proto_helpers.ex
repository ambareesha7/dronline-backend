defmodule Web.ProtoHelpers do
  def map_us_board_second_opinion_status(status) when is_atom(status) do
    status
    |> uppercase_atom()
    |> Proto.enum(Proto.Visits.USBoardSecondOpinionRequest.Status)
  end

  def map_account_deletion_status(status) when is_atom(status) do
    status
    |> uppercase_atom()
    |> Proto.enum(Proto.AdminPanel.AccountDeletion.Status)
  end

  def map_account_deletion_type(type) when is_atom(type) do
    type
    |> uppercase_atom()
    |> Proto.enum(Proto.AdminPanel.AccountDeletion.Type)
  end

  def map_payment_method(nil) do
    Proto.enum(:EXTERNAL, Proto.Visits.PaymentsParams.PaymentMethod)
  end

  def map_payment_method(payment_method) when is_atom(payment_method) do
    payment_method
    |> uppercase_atom()
    |> Proto.enum(Proto.Visits.PaymentsParams.PaymentMethod)
  end

  defp uppercase_atom(atom) when is_atom(atom) do
    atom
    |> Atom.to_string()
    |> String.upcase()
    |> String.to_existing_atom()
  end
end
