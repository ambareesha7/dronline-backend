defmodule Postgres.Repo.Migrations.AddUniqueIndexOntimelinesTablePatienIdUsBoardRequestId do
  use Ecto.Migration

  def change do
    # Index name has to be shorter or equal to 64 chaar, otherwise it's truncated
    # and that lead to small and easy to fix, but still: bugs!!! 😨
    create unique_index(:timelines, [:patient_id, :us_board_request_id],
             where: "type = 'US_BOARD' AND active = true",
             name: "unique_status_call_scheduled_second_opinion_index"
           )
  end
end
