defmodule Postgres.Seeds.InsuranceProvider do
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

defmodule Postgres.Seeds.InsuranceProviders do
  use Postgres.Service

  alias Postgres.Seeds.InsuranceProvider

  def seed do
    now = NaiveDateTime.utc_now()

    [
      %{
        name: "UnitedHealth",
        country_id: "us"
      },
      %{
        name: "Kaiser Foundation",
        country_id: "us"
      },
      %{
        name: "Anthem Inc.",
        country_id: "us"
      },
      %{
        name: "Humana",
        country_id: "us"
      },
      %{
        name: "CVS",
        country_id: "us"
      },
      %{
        name: "Health Care Service Corporation (HCSC)",
        country_id: "us"
      },
      %{
        name: "Centene Corp",
        country_id: "us"
      },
      %{
        name: "Cigna Health",
        country_id: "us"
      },
      %{
        name: "Wellcare",
        country_id: "us"
      },
      %{
        name: "Molina Healthcare Inc.",
        country_id: "us"
      },
      %{
        name: "Guidewell Mut Holding",
        country_id: "us"
      },
      %{
        name: "California Physicians Service",
        country_id: "us"
      },
      %{
        name: "Independence Health Group Inc.",
        country_id: "us"
      },
      %{
        name: "Blue Cross of California",
        country_id: "us"
      },
      %{
        name: "Highmark Group",
        country_id: "us"
      },
      %{
        name: "Blue Cross Blue Shield of Michigan",
        country_id: "us"
      },
      %{
        name: "Blue Cross Blue Shield of New Jersey",
        country_id: "us"
      },
      %{
        name: "Caresource",
        country_id: "us"
      },
      %{
        name: "Blue Cross Blue Shield of North Carolina",
        country_id: "us"
      },
      %{
        name: "Carefirst Inc.",
        country_id: "us"
      },
      %{
        name: "Health Net of California, Inc.",
        country_id: "us"
      },
      %{
        name: "UPMC Health System",
        country_id: "us"
      },
      %{
        name: "Blue Cross Blue Shield of Massachusetts",
        country_id: "us"
      },
      %{
        name: "Blue Cross Blue Shield of Tennessee",
        country_id: "us"
      },
      %{
        name: "Metropolitan",
        country_id: "us"
      }
    ]
    |> Enum.each(fn provider ->
      InsuranceProvider
      |> Repo.get_by(name: provider.name)
      |> Kernel.||(%InsuranceProvider{})
      |> Ecto.Changeset.change(
        name: provider.name,
        country_id: provider.country_id,
        logo_url: provider[:logo_url],
        inserted_at: now,
        updated_at: now
      )
      |> Repo.insert_or_update!()
    end)
  end
end
