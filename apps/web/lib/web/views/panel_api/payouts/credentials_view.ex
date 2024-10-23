defmodule Web.PanelApi.Payouts.CredentialsView do
  use Web, :view

  def render("show.proto", %{credentials: nil}) do
    %{credentials: nil}
    |> Proto.Payouts.GetCredentialsResponse.new()
  end

  def render("show.proto", %{credentials: credentials}) do
    %{
      credentials: %Proto.Payouts.Credentials{
        iban: credentials.iban,
        name: credentials.name,
        address: credentials.address,
        bank_name: credentials.bank_name,
        bank_address: credentials.bank_address,
        bank_swift_code: credentials.bank_swift_code,
        bank_routing_number: credentials.bank_routing_number
      }
    }
    |> Proto.validate!(Proto.Payouts.GetCredentialsResponse)
    |> Proto.Payouts.GetCredentialsResponse.new()
  end
end
