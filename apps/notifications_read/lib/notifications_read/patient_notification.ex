defmodule NotificationsRead.PatientNotification do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:id, :binary_id, autogenerate: false}
  schema "patient_notifications" do
    field :for_patient_id, :integer
    field :specialist_id, :integer

    belongs_to :medical_summary, EMR.PatientRecords.MedicalSummary
    belongs_to :tests_bundle, EMR.PatientRecords.OrderedTestsBundle
    belongs_to :medications_bundle, EMR.PatientRecords.MedicationsBundle

    field :read, :boolean

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  @spec fetch_for_patient(pos_integer, map) ::
          {:ok, [%__MODULE__{}], [pos_integer], String.t()}
  def fetch_for_patient(patient_id, params) do
    {:ok, result, next_token} =
      __MODULE__
      |> where(for_patient_id: ^patient_id)
      |> where(^Postgres.Option.next_token(params, :inserted_at, :desc))
      |> join(:left, [n], ms in assoc(n, :medical_summary))
      |> join(:left, [n], tb in assoc(n, :tests_bundle))
      |> join(:left, [n], mb in assoc(n, :medications_bundle))
      |> preload(
        [n, ms, tb, mb],
        medical_summary: ms,
        tests_bundle: tb,
        medications_bundle: mb
      )
      |> order_by(desc: :inserted_at)
      |> Repo.fetch_paginated(params, :inserted_at)

    {:ok, result, parse_specialist_ids(result), parse_next_token(next_token)}
  end

  @spec get_unread_count_for_patient(pos_integer) :: non_neg_integer
  def get_unread_count_for_patient(patient_id) do
    __MODULE__
    |> where(for_patient_id: ^patient_id, read: false)
    |> select(count())
    |> Repo.one()
  end

  defp parse_next_token(nil), do: ""
  defp parse_next_token(nt), do: DateTime.to_iso8601(nt)

  defp parse_specialist_ids(notifications) do
    notifications
    |> Enum.map(& &1.specialist_id)
    |> Enum.uniq()
  end
end
