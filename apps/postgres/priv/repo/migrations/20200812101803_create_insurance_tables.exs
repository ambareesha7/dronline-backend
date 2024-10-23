defmodule Postgres.Repo.Migrations.CreateInsuranceTables do
  use Ecto.Migration

  def change do
    create table(:insurance_providers) do
      add :name, :string, null: false
      add :logo_url, :string

      add :country_id,
          references(:countries, on_delete: :delete_all, type: :string),
          null: false

      timestamps()
    end

    create index(:insurance_providers, [:country_id])
    create unique_index(:insurance_providers, [:name, :country_id])

    create table(:insurance_accounts) do
      add :patient_id, :integer, null: false
      add :member_id, :string, null: false

      add :provider_id, references(:insurance_providers, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:insurance_accounts, [:patient_id, :provider_id, :member_id])

    alter table(:timelines) do
      add :insurance_account_id, references(:insurance_accounts)
    end

    alter table(:patients) do
      add :insurance_account_id, references(:insurance_accounts)
    end
  end
end
