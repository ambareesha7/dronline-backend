defmodule UrgentCare.RequestFactory do
  alias Postgres.Repo
  alias UrgentCare.Payments.Payment
  alias UrgentCare.Request

  require Money

  def insert(params \\ %{}) do
    default_params = %{
      patient_id: Map.get(params, :patient_id, 956),
      patient_record_id: Map.get(params, :patient_record_id, 675),
      specialist_id: 200,
      team_id: 1
    }

    {:ok, urgent_care_request} = Request.create(Map.merge(default_params, Enum.into(params, %{})))

    create_payment(urgent_care_request.id)

    urgent_care_request
  end

  defp create_payment(urgent_care_request_id) do
    current_time = DateTime.utc_now() |> DateTime.to_naive()

    payment = %Payment{
      urgent_care_request_id: urgent_care_request_id,
      transaction_reference: "DEFAULT_REF",
      payment_method: :telr,
      price: Money.new(100, :USD),
      inserted_at: current_time
    }

    Repo.insert(payment)
  end
end
