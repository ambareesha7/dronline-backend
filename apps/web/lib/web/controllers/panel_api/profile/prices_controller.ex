defmodule Web.PanelApi.Profile.PricesController do
  use Web, :controller

  action_fallback Web.FallbackController

  def index(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id

    categories_prices = SpecialistProfile.fetch_prices(specialist_id)
    :ok = SpecialistProfile.Status.mark_pricing_tables_seen(specialist_id)

    conn
    |> render("index.proto", %{categories_prices: categories_prices})
  end

  @decode Proto.SpecialistProfile.UpdatePricesRequest
  def update(conn, _params) do
    specialist_id = conn.assigns.current_specialist_id
    prices_proto = conn.assigns.protobuf.category_prices |> Map.from_struct()

    with {:ok, category_prices} <- SpecialistProfile.update_prices(specialist_id, prices_proto) do
      conn
      |> render("update.proto", %{category_prices: category_prices})
    end
  end
end

defmodule Web.PanelApi.Profile.PricesView do
  use Web, :view

  def render("index.proto", %{categories_prices: categories_prices}) do
    %Proto.SpecialistProfile.GetPricesResponse{
      categories_prices:
        render_many(categories_prices, Proto.SpecialistProfileView, "category_prices.proto",
          as: :category_prices
        )
    }
  end

  def render("update.proto", %{category_prices: category_prices}) do
    %Proto.SpecialistProfile.UpdatePricesResponse{
      category_prices:
        render_one(category_prices, Proto.SpecialistProfileView, "category_prices.proto",
          as: :category_prices
        )
    }
  end
end
