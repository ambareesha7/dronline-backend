defmodule Payouts.PendingWithdrawals.PendingWithdrawal do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:record_id, :integer, autogenerate: false}
  schema "pending_withdrawals" do
    field :patient_id, :integer
    field :specialist_id, :integer
    field :visit_id, :binary_id
    field :amount, :integer
    field :medical_category_id, :integer, virtual: true

    timestamps()
  end

  def create(params) do
    params
    |> changeset()
    |> Repo.insert(on_conflict: :nothing)
  end

  @fields [:record_id, :patient_id, :specialist_id, :amount]
  defp changeset(params) do
    %__MODULE__{}
    |> cast(params, @fields)
    |> validate_required(@fields)
  end
end
