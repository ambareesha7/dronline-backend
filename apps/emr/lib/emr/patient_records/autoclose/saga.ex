defmodule EMR.PatientRecords.Autoclose.Saga do
  @moduledoc """
  Implements business process of record autoclose

  ADR-003
  """

  use Postgres.Schema
  use Postgres.Service

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "records_autoclose_saga" do
    field :state, Postgres.EctoType.Term, source: :encoded_state, default: []

    field :patient_id, :integer
    field :record_id, :integer

    timestamps()
  end

  @spec register_pending_medical_summary(pos_integer, pos_integer, pos_integer) :: :ok
  def register_pending_medical_summary(patient_id, record_id, specialist_id)
      when is_integer(patient_id) and is_integer(record_id) and is_integer(specialist_id) do
    saga = get_by(patient_id, record_id)

    new_state = saga.state ++ [{:pending_summary, specialist_id}]

    handle_new_state(saga, new_state)
  end

  @spec register_provided_medical_summary(pos_integer, pos_integer, pos_integer) :: :ok
  def register_provided_medical_summary(patient_id, record_id, specialist_id)
      when is_integer(patient_id) and is_integer(record_id) and is_integer(specialist_id) do
    saga = get_by(patient_id, record_id)

    new_state = saga.state -- [{:pending_summary, specialist_id}]

    handle_new_state(saga, new_state)
  end

  @spec register_dispatch_request(pos_integer, pos_integer, String.t()) :: :ok
  def register_dispatch_request(patient_id, record_id, request_id)
      when is_integer(patient_id) and is_integer(record_id) do
    saga = get_by(patient_id, record_id)

    new_state = saga.state ++ [{:dispatch_request, request_id}]

    handle_new_state(saga, new_state)
  end

  @spec register_dispatch_end(pos_integer, pos_integer, String.t()) :: :ok
  def register_dispatch_end(patient_id, record_id, request_id)
      when is_integer(patient_id) and is_integer(record_id) do
    saga = get_by(patient_id, record_id)

    new_state = saga.state -- [{:dispatch_request, request_id}]

    handle_new_state(saga, new_state)
  end

  defp get_by(patient_id, record_id) do
    Repo.get_by(__MODULE__, patient_id: patient_id, record_id: record_id) ||
      %__MODULE__{patient_id: patient_id, record_id: record_id}
  end

  defp handle_new_state(saga, []) do
    _ = EMR.PatientRecords.PatientRecord.close(saga.patient_id, saga.record_id)

    {:ok, _} =
      saga
      |> cast(%{state: []}, [:state])
      |> Repo.insert_or_update()

    :ok
  end

  defp handle_new_state(saga, new_state) do
    {:ok, _} =
      saga
      |> cast(%{state: Enum.uniq(new_state)}, [:state])
      |> Repo.insert_or_update()

    :ok
  end
end
