defmodule Postgres.Repo.Migrations.AddUsBoardSecondOpinionRequestPayments do
  use Ecto.Migration

  def change do
    create table(:us_board_second_opinion_request_payments, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :us_board_second_opinion_request_id,
          references(:us_board_second_opinion_requests, type: :binary_id, on_delete: :nothing),
          null: false

      add :patient_id, references(:patients, on_delete: :nothing), null: false
      add :specialist_id, references(:specialists, on_delete: :nothing)
      add :team_id, references(:specialist_teams, on_delete: :nothing)
      add :transaction_reference, :string
      add :payment_method, :string
      add :price, :money_with_currency

      timestamps()
    end

    create index(:us_board_second_opinion_request_payments, [:us_board_second_opinion_request_id])
    create index(:us_board_second_opinion_request_payments, [:patient_id])
    create index(:us_board_second_opinion_request_payments, [:specialist_id])
    create index(:us_board_second_opinion_request_payments, [:team_id])
    create index(:us_board_second_opinion_request_payments, [:payment_method])
  end
end
