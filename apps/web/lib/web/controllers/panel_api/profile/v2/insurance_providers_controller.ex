defmodule Web.PanelApi.Profile.V2.InsuranceProvidersController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id
    {:ok, insurance_providers} = SpecialistProfile.fetch_insurances(specialist_id)

    render(conn, "show.proto", %{insurance_providers: insurance_providers})
  end

  @decode Proto.SpecialistProfileV2.UpdateInsuranceProvidersRequestV2
  def update(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id
    insurance_providers_ids = Enum.map(conn.assigns.protobuf.insurance_providers, & &1.id)

    with {:ok, providers} <-
           SpecialistProfile.update_insurance_providers(specialist_id, insurance_providers_ids) do
      render(conn, "update.proto", %{insurance_providers: providers})
    end
  end
end

defmodule Web.PanelApi.Profile.V2.InsuranceProvidersView do
  use Web, :view

  def render("show.proto", %{insurance_providers: insurance_providers}) do
    %Proto.SpecialistProfileV2.GetInsuranceProvidersV2{
      insurance_providers:
        Web.View.SpecialistProfileV2.render_insurance_providers(insurance_providers)
    }
  end

  def render("update.proto", %{insurance_providers: insurance_providers}) do
    %Proto.SpecialistProfileV2.UpdateInsuranceProvidersResponseV2{
      insurance_providers:
        Web.View.SpecialistProfileV2.render_insurance_providers(insurance_providers)
    }
  end
end
