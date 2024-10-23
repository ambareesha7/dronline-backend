defmodule Postgres.Repo.Migrations.ChangeUsBoardRequestPatientId do
  use Ecto.Migration

  def change do
    alter table(:us_board_second_opinion_requests) do
      modify :patient_id, :integer, null: true
    end
  end
end
