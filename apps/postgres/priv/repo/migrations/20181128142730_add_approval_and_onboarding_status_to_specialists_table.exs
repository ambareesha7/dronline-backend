defmodule Postgres.Repo.Migrations.AddApprovalStatusToSpecialistsTable do
  use Ecto.Migration

  def change do
    alter table(:specialists) do
      add :approval_status, :string, null: false, default: "waiting"
      add :onboarding_completed, :boolean, null: false, default: false
    end

    create index(:specialists, [:approval_status])
  end
end
