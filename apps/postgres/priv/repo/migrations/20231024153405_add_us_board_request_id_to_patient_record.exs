defmodule Postgres.Repo.Migrations.AddUsBoardRequestIdToPatientRecord do
  use Ecto.Migration

  def change do
    alter table(:timelines) do
      add :us_board_request_id, :string
    end
  end
end
