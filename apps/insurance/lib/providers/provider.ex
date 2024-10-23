defmodule Insurance.Providers.Provider do
  use Postgres.Schema
  use Postgres.Service

  alias Postgres.Seeds.Country

  schema "insurance_providers" do
    field :name, :string
    field :logo_url, :string

    belongs_to :country, Country, type: :string

    timestamps()
  end
end
