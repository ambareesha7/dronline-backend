defmodule Payouts.PendingWithdrawals.Visit do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:id, :binary_id, autogenerate: false}

  schema "visits_log" do
    field :chosen_medical_category_id, :integer
    field :record_id, :integer
  end

  def get_by_record_id(record_id) do
    __MODULE__
    |> where(record_id: ^record_id)
    |> Repo.fetch_one()
  end
end
