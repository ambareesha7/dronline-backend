defmodule Postgres.Repo.Migrations.CreateNewMedications do
  use Ecto.Migration

  def change do
    create table(:new_medications, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("uuid_generate_v4()")
      add :name, :string
      add :price, :float
      add :currency, :string

      timestamps(default: fragment("now()"))
    end

    create index(:new_medications, [:name])
  end
end
