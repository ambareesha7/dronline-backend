defmodule Postgres.Repo.Migrations.ExtractBmiToSeparateTable do
  use Ecto.Migration

  def change do
    alter table(:user_basic_infos) do
      remove :height
      remove :weight
    end

    create table(:user_bmis) do
      add :height, :integer
      add :weight, :integer

      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create index(:user_bmis, [:user_id])
  end
end
