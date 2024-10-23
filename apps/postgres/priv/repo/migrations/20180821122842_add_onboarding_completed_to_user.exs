defmodule Postgres.Repo.Migrations.AddOnboardingCompletedToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :onboarding_completed, :boolean, default: false, null: false
    end
  end
end
