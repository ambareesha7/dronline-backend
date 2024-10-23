defmodule Postgres.Repo.Migrations.ChildHistory do
  use Ecto.Migration

  def change do
    create table(:child_history_forms) do
      add :social, :binary
      add :medical, :binary
      add :surgical, :binary
      add :family, :binary
      add :allergy, :binary
      add :immunization, :binary

      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :child_id, references(:children, on_delete: :delete_all), null: false
    end

    create index(:child_history_forms, [:user_id])
    create index(:child_history_forms, [:child_id])
  end
end
