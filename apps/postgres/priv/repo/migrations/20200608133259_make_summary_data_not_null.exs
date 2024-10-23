defmodule Postgres.Repo.Migrations.MakeSummaryDataNotNull do
  use Ecto.Migration

  def up do
    execute "UPDATE medical_summaries SET data='' WHERE data IS NULL;"

    alter table(:medical_summaries) do
      modify :data, :binary, null: false, default: ""
    end
  end

  def down do
    alter table(:medical_summaries) do
      modify :data, :binary, null: true
    end
  end
end
