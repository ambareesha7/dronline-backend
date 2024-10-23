defmodule Postgres.Repo.Migrations.AddSpecialistTrialEndsAt do
  use Ecto.Migration
  import Ecto.Query

  def up do
    alter table(:specialists) do
      add :trial_ends_at, :naive_datetime,
        null: false,
        default: fragment("NOW() + INTERVAL '3 MONTH'")
    end

    "specialists"
    |> where([s], not like(s.email, "%@appunite.com%"))
    |> Postgres.Repo.update_all(set: [package_type: "PLATINUM"])
  end

  def down do
    alter table(:specialists) do
      remove :trial_ends_at
    end
  end
end
