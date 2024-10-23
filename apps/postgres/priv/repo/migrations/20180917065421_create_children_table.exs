defmodule Postgres.Repo.Migrations.CreateChildrenTable do
  use Ecto.Migration

  def change do
    create table(:children) do
      add :relationship, :string
      add :first_name, :string
      add :last_name, :string
      add :birth_date, :date
      add :height, :integer
      add :weight, :integer

      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create index(:children, [:user_id])
  end
end
