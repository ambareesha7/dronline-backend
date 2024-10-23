defmodule Postgres.Repo.Migrations.UserHpi do
  use Ecto.Migration

  def change do
    create table(:user_hpis) do
      add :form, :binary

      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create index(:user_hpis, [:user_id])
  end
end
