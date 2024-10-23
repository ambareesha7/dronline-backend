defmodule Web.PublicApi.CountriesController do
  use Web, :controller
  import Ecto.Query

  alias Postgres.Repo
  alias Postgres.Seeds.Country

  def index(conn, _params) do
    countries =
      Country
      |> order_by(asc: :name)
      |> Repo.all()

    conn |> render("index.proto", %{countries: countries})
  end
end

defmodule Web.PublicApi.CountriesView do
  use Web, :view

  def render("index.proto", %{countries: countries}) do
    %Proto.Generics.Countries{
      countries:
        Enum.map(countries, fn country ->
          %Proto.Generics.Country{
            id: country.id,
            name: country.name,
            dial_code: country.dial_code
          }
        end)
    }
  end
end
