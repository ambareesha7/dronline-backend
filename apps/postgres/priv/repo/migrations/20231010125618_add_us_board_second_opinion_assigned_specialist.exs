defmodule Postgres.Repo.Migrations.AddUsBoardSecondOpinionAssignedSpecialist do
  use Ecto.Migration

  def change do
    create table(:us_board_second_opinion_assigned_specialists, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :us_board_second_opinion_request_id,
          references(:us_board_second_opinion_requests, type: :binary_id, on_delete: :nothing),
          null: false

      add :specialist_id, :integer, null: false
      add :assigned_at, :utc_datetime
      add :accepted_at, :utc_datetime
      add :rejected_at, :utc_datetime
      add :status, :string

      timestamps()
    end

    create index(:us_board_second_opinion_assigned_specialists, [:specialist_id])

    create index(
             :us_board_second_opinion_assigned_specialists,
             [:us_board_second_opinion_request_id]
           )
  end
end
