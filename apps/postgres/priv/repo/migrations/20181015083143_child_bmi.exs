defmodule Postgres.Repo.Migrations.ChildBmi do
  use Ecto.Migration

  def change do
    alter table(:children) do
      remove :height
      remove :weight
    end

    create table(:child_bmis) do
      add :height, :integer
      add :weight, :integer

      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :child_id, references(:children, on_delete: :delete_all), null: false
    end

    create index(:child_bmis, [:user_id])
    create index(:child_bmis, [:child_id])
  end
end
