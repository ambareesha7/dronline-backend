defmodule Postgres.Repo.Migrations.AddUsBoardRequest do
  use Ecto.Migration

  def change do
    create table(:us_board_second_opinion_requests, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :patient_id, :integer, null: false
      add :visit_id, :integer
      add :patient_description, :text
      add :specialist_opinion, :text
      add :patient_email, :string
      add :status, :string
      add :files, {:array, :map}

      timestamps()
    end

    create index(:us_board_second_opinion_requests, [:patient_id])
    create index(:us_board_second_opinion_requests, [:visit_id])
  end
end
