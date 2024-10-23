defmodule Web.Common.Visits.VisitView do
  use Web, :view

  def render("payment.proto", %{payment: payment, record_id: record_id}) do
    %Proto.Visits.GetPaymentForVisit{
      amount: parse_amount(payment.price.amount),
      currency: parse_currency(payment.price.currency),
      record_id: record_id,
      payment_method: parse_payment_method(payment.payment_method)
    }
  end

  defp parse_payment_method(:telr), do: "by card"
  defp parse_payment_method(:external), do: "in office"
  defp parse_payment_method(nil), do: ""

  defp parse_amount(amount) when is_integer(amount), do: Integer.to_string(amount)
  defp parse_amount(amount) when is_binary(amount), do: amount
  defp parse_amount(nil), do: 0

  defp parse_currency(nil), do: ""
  defp parse_currency(currency), do: Atom.to_string(currency)
end
