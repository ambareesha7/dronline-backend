defmodule Postgres.Repo.Migrations.RenameOperatorToGp do
  use Ecto.Migration

  def change do
    execute("UPDATE specialists SET type = 'GP' WHERE type = 'OPERATOR'")

    rename table(:dispatch_requests), :operator_id, to: :gp_id
    rename table(:dispatches), :operator_id, to: :gp_id
  end
end
