defmodule Postgres.Repo.Migrations.BloodPressure do
  use Ecto.Migration

  def change do
    create table(:user_blood_pressures) do
      add :systolic, :integer
      add :diastolic, :integer
      add :pulse, :integer

      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create index(:user_blood_pressures, [:user_id])
  end
end
