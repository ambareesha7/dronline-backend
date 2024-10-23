defmodule Postgres.Seeds.Country do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:id, :string, autogenerate: false}
  schema "countries" do
    field :name, :string
    field :dial_code, :string
  end
end

defmodule Postgres.Seeds.Countries do
  use Postgres.Service

  alias Postgres.Seeds.Country

  def seed do
    countries =
      [
        %{
          name: "USA",
          iso2_code: "us",
          dial_code: "1"
        },
        %{
          name: "Brazil",
          iso2_code: "br",
          dial_code: "55"
        },
        %{
          name: "UK",
          iso2_code: "gb",
          dial_code: "44"
        },
        %{
          name: "Germany",
          iso2_code: "de",
          dial_code: "49"
        },
        %{
          name: "Italy",
          iso2_code: "it",
          dial_code: "39"
        },
        %{
          name: "Spain",
          iso2_code: "es",
          dial_code: "34"
        },
        %{
          name: "France",
          iso2_code: "fr",
          dial_code: "33"
        },
        %{
          name: "Poland",
          iso2_code: "pl",
          dial_code: "48"
        },
        %{
          name: "Russia",
          iso2_code: "ru",
          dial_code: "7"
        },
        %{
          name: "Turkey",
          iso2_code: "tr",
          dial_code: "90"
        },
        %{
          name: "Nigeria",
          iso2_code: "ng",
          dial_code: "234"
        },
        %{
          name: "Zambia",
          iso2_code: "zm",
          dial_code: "260"
        },
        %{
          name: "Egypt",
          iso2_code: "eg",
          dial_code: "20"
        },
        %{
          name: "South Africa",
          iso2_code: "so",
          dial_code: "252"
        },
        %{
          name: "Saudi Arabia",
          iso2_code: "sa",
          dial_code: "966"
        },
        %{
          name: "Kuwait",
          iso2_code: "kw",
          dial_code: "965"
        },
        %{
          name: "Oman",
          iso2_code: "om",
          dial_code: "968"
        },
        %{
          name: "Jordan",
          iso2_code: "jo",
          dial_code: "962"
        },
        %{
          name: "Lebanon",
          iso2_code: "lb",
          dial_code: "961"
        },
        %{
          name: "Syria",
          iso2_code: "sy",
          dial_code: "963"
        },
        %{
          name: "Iraq",
          iso2_code: "iq",
          dial_code: "964"
        },
        %{
          name: "India",
          iso2_code: "in",
          dial_code: "91"
        },
        %{
          name: "Pakistan",
          iso2_code: "pk",
          dial_code: "92"
        },
        %{
          name: "United Arab Emirates",
          iso2_code: "ae",
          dial_code: "971"
        }
      ]
      |> Enum.map(fn c ->
        %{
          id: c.iso2_code,
          name: c.name,
          dial_code: c.dial_code
        }
      end)

    Country
    |> Repo.insert_all(countries, on_conflict: :replace_all, conflict_target: :id)
  end
end
