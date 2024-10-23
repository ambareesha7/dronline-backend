defmodule Web.Api.Specialists.InsuranceProvidersController do
  use Web, :controller

  action_fallback Web.FallbackController

  def index(conn, params) do
    specialist_id = String.to_integer(params["specialist_id"])
    patient_id = conn.assigns.current_patient_id

    {:ok, specialist_providers} = SpecialistProfile.fetch_insurances(specialist_id)
    {:ok, patient_provider} = Insurance.fetch_by_patient_id(patient_id)

    render(conn, "index.proto", %{
      insurance_providers: specialist_providers,
      matching_provider: get_matching_provider(patient_provider, specialist_providers)
    })
  end

  defp get_matching_provider(
         %Insurance.Accounts.Account{} = patient_provider,
         specialist_providers
       ) do
    if specialist_providers |> Enum.map(& &1.id) |> Enum.member?(patient_provider.provider_id) do
      %{id: patient_provider.provider_id, name: patient_provider.insurance_provider.name}
    else
      %{id: nil, name: nil}
    end
  end

  defp get_matching_provider(_patient_provider, _specialist_providers) do
    %{id: nil, name: nil}
  end
end

defmodule Web.Api.Specialists.InsuranceProvidersView do
  use Web, :view

  def render("index.proto", %{
        insurance_providers: insurance_providers,
        matching_provider: matching_provider
      }) do
    %Proto.SpecialistProfileV2.GetInsuranceProvidersV2{
      insurance_providers:
        Web.View.SpecialistProfileV2.render_insurance_providers(insurance_providers),
      matching_provider:
        Web.View.SpecialistProfileV2.render_insurance_matching_provider(matching_provider)
    }
  end
end
