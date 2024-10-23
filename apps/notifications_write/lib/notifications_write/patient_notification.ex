defmodule NotificationsWrite.PatientNotification do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "patient_notifications" do
    field :for_patient_id, :integer
    field :specialist_id, :integer
    field :read, :boolean

    field :medical_summary_id, :integer
    field :tests_bundle_id, :integer
    field :medications_bundle_id, :integer

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  @spec notify_about_record_change(pos_integer, pos_integer, pos_integer, nil | Keyword.t()) ::
          :ok
  def notify_about_record_change(record_id, patient_id, specialist_id, opts) do
    _ =
      Repo.insert_all(__MODULE__, [
        insertion_content(patient_id, specialist_id, opts)
      ])

    _ = send_push_notifications(patient_id, record_id)

    :ok
  end

  defp insertion_content(patient_id, specialist_id, opts) do
    %{
      for_patient_id: patient_id,
      specialist_id: specialist_id,
      inserted_at: DateTime.utc_now(),
      medical_summary_id: opts[:medical_summary_id],
      tests_bundle_id: opts[:tests_bundle_id],
      medications_bundle_id: opts[:medications_bundle_id]
    }
  end

  defp send_push_notifications(patient_id, record_id) do
    PushNotifications.Message.send(%PushNotifications.Message.NewPatientNotification{
      send_to_patient_id: patient_id,
      record_id: record_id
    })
  end

  @spec mark_notification_as_read(pos_integer, String.t()) :: :ok
  def mark_notification_as_read(patient_id, notification_id) do
    __MODULE__
    |> where(for_patient_id: ^patient_id, id: ^notification_id)
    |> Repo.update_all(set: [read: true])
    |> case do
      {1, _} ->
        :ok

      _ ->
        raise "#{inspect(__MODULE__)}.mark_notification_as_read/2 failure"
    end
  end

  @spec mark_all_notifications_as_read(pos_integer) :: :ok
  def mark_all_notifications_as_read(patient_id) do
    _ =
      __MODULE__
      |> where(for_patient_id: ^patient_id)
      |> Repo.update_all(set: [read: true])

    :ok
  end
end
