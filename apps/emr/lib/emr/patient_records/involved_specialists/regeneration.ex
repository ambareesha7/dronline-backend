defmodule EMR.PatientRecords.InvolvedSpecialists.Regeneration do
  @moduledoc """
  Contains functions to regenerate InvolvedSpecialists table based on past data

  This module is meant to be used from console

      PatientProfile.Schema
      |> Postgres.Repo.all()
      |> Enum.map(& &1.id)
      |> Enum.each(&EMR.PatientRecords.InvolvedSpecialists.Regeneration.regenerate_for_patient/1)

  """

  use Postgres.Service

  alias EMR.PatientRecords.InvolvedSpecialists

  @doc false
  def regenerate_for_patient(patient_id) do
    records = EMR.PatientRecords.PatientRecord |> where(patient_id: ^patient_id) |> Repo.all()

    Enum.each(records, &regenerate_for_record(patient_id, &1.id))
  end

  @doc false
  def regenerate_for_record(patient_id, record_id) do
    register_record_creator(patient_id, record_id)
    register_timeline_items_specialists(patient_id, record_id)
  end

  defp register_record_creator(patient_id, record_id) do
    case Repo.get_by(EMR.PatientRecords.PatientRecord, patient_id: patient_id, id: record_id) do
      %{created_by_specialist_id: nil} ->
        :ok

      %{created_by_specialist_id: created_by_specialist_id} ->
        InvolvedSpecialists.register_involvement(patient_id, record_id, created_by_specialist_id)
    end
  end

  defp register_timeline_items_specialists(patient_id, record_id) do
    {:ok, _timeline, specialist_ids} = EMR.PatientRecords.Timeline.fetch_by_id(record_id)

    Enum.each(specialist_ids, fn specialist_id ->
      InvolvedSpecialists.register_involvement(patient_id, record_id, specialist_id)
    end)
  end
end
