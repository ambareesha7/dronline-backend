defmodule Postgres.Repo.Migrations.AddPhoneToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :phone_number, :string, null: false
    end

    create unique_index(:users, [:phone_number])
  end
end
