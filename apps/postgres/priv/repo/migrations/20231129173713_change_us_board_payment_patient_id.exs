defmodule Postgres.Repo.Migrations.ChangeUsBoardPaymentPatientId do
  use Ecto.Migration

  def change do
    alter table(:us_board_second_opinion_request_payments) do
      modify :patient_id, :integer, null: true
    end
  end
end
