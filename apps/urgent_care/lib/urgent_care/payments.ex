defmodule UrgentCare.Payments do
  alias Postgres.Repo
  alias UrgentCare.Payments.Refund

  use Postgres.Service

  def create_refund(params) do
    %Refund{}
    |> Refund.changeset(params)
    |> Repo.insert()
  end

  def get_refund_for_payment(payment_id) do
    Repo.get_by(Refund, payment_id: payment_id)
  end
end
