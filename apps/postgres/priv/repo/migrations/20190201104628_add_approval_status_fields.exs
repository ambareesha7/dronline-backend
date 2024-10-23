defmodule Postgres.Repo.Migrations.AddApprovalStatusFields do
  use Ecto.Migration

  def change do
    alter table(:specialists) do
      modify :approval_status, :string, null: false, default: "WAITING"
      add :approval_status_updated_at, :naive_datetime_usec
    end

    execute "UPDATE specialists SET approval_status = 'WAITING'"
  end
end
