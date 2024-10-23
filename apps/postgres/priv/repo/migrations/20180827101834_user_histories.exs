defmodule Postgres.Repo.Migrations.UserHistories do
  use Ecto.Migration

  def change do
    create table(:user_history_forms) do
      add :social, :binary
      add :medical, :binary
      add :surgical, :binary
      add :family, :binary
      add :allergy, :binary
      add :immunization, :binary

      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create index(:user_history_forms, [:user_id])
  end
end
