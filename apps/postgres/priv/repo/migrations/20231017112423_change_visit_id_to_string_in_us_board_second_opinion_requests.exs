defmodule Postgres.Repo.Migrations.ChangeVisitIdToStringInUsBoardSecondOpinionRequests do
  use Ecto.Migration

  def change do
    alter table(:us_board_second_opinion_requests) do
      modify :visit_id, :string
    end
  end
end
