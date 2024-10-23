defmodule Web.Api.InsuranceProvidersController do
  use Web, :controller

  action_fallback Web.FallbackController

  def index(conn, %{"country" => country}) do
    with {:ok, providers} <- Insurance.get_providers_for_country(country) do
      conn |> render("index.proto", %{providers: providers})
    end
  end
end

defmodule Web.Api.InsuranceProvidersView do
  use Web, :view

  def render("index.proto", %{providers: providers}) do
    %Proto.Insurance.GetProvidersResponse{
      providers:
        providers
        |> Enum.map(
          &%Proto.Insurance.Provider{
            id: &1.id,
            name: &1.name,
            logo_url: &1.logo_url
          }
        )
    }
  end
end
