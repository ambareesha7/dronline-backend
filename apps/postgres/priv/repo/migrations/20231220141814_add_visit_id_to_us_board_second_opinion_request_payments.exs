defmodule Postgres.Repo.Migrations.AddVisitIdToUsBoardSecondOpinionRequestPayments do
  use Ecto.Migration

  def change do
    alter table(:us_board_second_opinion_request_payments) do
      add :visit_id, :integer
    end
  end
end
