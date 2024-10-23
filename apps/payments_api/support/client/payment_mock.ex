defmodule PaymentsApi.Client.PaymentMock do
  def get_payment_url(params) do
    {:ok,
     %{
       payment_url: "https://secure.telr.com/gateway/process.html?o=#{params.ref}",
       ref: params.ref
     }}
  end
end
