defmodule Web.Api.Specialists.PricesController do
  use Web, :controller

  action_fallback Web.FallbackController

  def index(conn, params) do
    specialist_id = String.to_integer(params["specialist_id"])

    categories_prices = SpecialistProfile.fetch_prices(specialist_id)

    conn
    |> render("index.proto", %{categories_prices: categories_prices})
  end
end

defmodule Web.Api.Specialists.PricesView do
  use Web, :view

  def render("index.proto", %{categories_prices: categories_prices}) do
    %Proto.SpecialistProfile.GetPricesResponse{
      categories_prices:
        render_many(categories_prices, Proto.SpecialistProfileView, "category_prices.proto",
          as: :category_prices
        )
    }
  end
end
