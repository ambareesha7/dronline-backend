defmodule UrgentCare.Request do
  use Postgres.Schema
  use Postgres.Service

  import Ecto.Query

  alias EMR.PatientRecords.PatientRecord
  alias UrgentCare.Payments.Payment

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "urgent_care_requests" do
    field :patient_id, :integer
    field :specialist_id, :integer
    field :team_id, :integer
    # PatientRecord is a "timelines" table in database it's nullable.
    belongs_to :patient_record, PatientRecord

    field :canceled_at, :utc_datetime_usec
    field :call_started_at, :utc_datetime_usec

    has_one :payment, Payment, foreign_key: :urgent_care_request_id

    timestamps()
  end

  def create(params) do
    %__MODULE__{}
    |> changeset(params)
    |> Repo.insert()
  end

  def fetch_by_record_id_for_pdf_summary(record_id) do
    __MODULE__
    |> where(patient_record_id: ^record_id)
    |> preload(:patient_record)
    |> preload(:payment)
    |> where([ucr], is_nil(ucr.canceled_at))
    |> Repo.fetch_one()
  end

  def cancel(id, canceled_at) do
    __MODULE__
    |> Repo.get!(id)
    |> Ecto.Changeset.change(canceled_at: canceled_at)
    |> Repo.update()
  end

  def mark_call_as_started(id, call_started_at) do
    __MODULE__
    |> Repo.get!(id)
    |> Ecto.Changeset.change(call_started_at: call_started_at)
    |> Repo.update()
  end

  def add_payment(id, payment_params) do
    __MODULE__
    |> preload(:payment)
    |> Repo.get!(id)
    |> Ecto.Changeset.change(payment: payment_params)
    |> Repo.update()
  end

  def add_patient_record(request, record_id) do
    request
    |> changeset(%{patient_record_id: record_id})
    |> Repo.update()
  end

  @required_fields [:patient_id]
  def changeset(struct, params) do
    struct
    |> cast(params, @required_fields ++ [:specialist_id, :team_id, :patient_record_id])
    |> validate_required(@required_fields)
    |> maybe_put_payment_assoc(params)
  end

  defp maybe_put_payment_assoc(changeset, params) do
    case Map.get(params, "payment") || Map.get(params, :payment) do
      nil ->
        changeset

      payment_params ->
        put_assoc(changeset, :payment, Payment.changeset(%Payment{}, payment_params))
    end
  end
end
