defmodule Postgres.Repo.Migrations.NewVitals do
  use Ecto.Migration

  def change do
    create table(:vitals_v2, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :height, :integer
      add :weight, :integer

      add :blood_pressure_systolic, :integer
      add :blood_pressure_diastolic, :integer
      add :pulse, :integer

      add :respiratory_rate, :integer
      add :body_temperature, :float
      add :physical_exam, :text

      add :patient_id, :bigint
      add :record_id, :bigint

      add :provided_by_nurse_id, :bigint

      timestamps()
    end

    create index(:vitals_v2, [:patient_id])
    create index(:vitals_v2, [:record_id])
    create index(:vitals_v2, [:inserted_at])
  end
end
