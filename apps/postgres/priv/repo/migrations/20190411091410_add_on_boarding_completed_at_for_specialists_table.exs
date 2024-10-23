defmodule Postgres.Repo.Migrations.AddOnBoardingCompletedAtForSpecialistsTable do
  use Ecto.Migration

  def change do
    alter table(:specialists) do
      add :onboarding_completed_at, :naive_datetime_usec
    end

    execute(
      "UPDATE specialists SET onboarding_completed_at = NOW() WHERE onboarding_completed = true
        OR (type != 'EXTERNAL' AND id in (SELECT specialist_id FROM specialist_basic_infos))",
      "UPDATE specialists SET onboarding_completed = true WHERE onboarding_completed_at IS NOT NULL"
    )

    alter table(:specialists) do
      remove :onboarding_completed, :boolean
    end
  end
end
