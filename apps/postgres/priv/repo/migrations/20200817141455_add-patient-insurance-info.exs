defmodule Postgres.Repo.Migrations.AddPatientInsuranceInfo do
  use Ecto.Migration

  def change do
    alter table(:patient_basic_infos) do
      add :is_insured, :boolean, default: false
      add :insurance_provider_name, :string
      add :insurance_member_id, :string
    end
  end
end
