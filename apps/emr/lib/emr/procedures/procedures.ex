defmodule EMR.Procedures do
  use Postgres.Service

  alias EMR.PatientRecords.MedicalSummary
  alias EMR.PatientsList

  @spec get_for_specialist(pos_integer, map) ::
          {:ok, [%MedicalSummary{}], next_token :: pos_integer | nil}
  def get_for_specialist(specialist_id, params) do
    connected_patients_ids = PatientsList.fetch_ids(specialist_id)

    MedicalSummary
    |> join(:inner, [ms], p in assoc(ms, :procedures))
    |> join(:inner, [ms, _p], t in assoc(ms, :timeline))
    |> where(
      [ms, _p, t],
      is_nil(ms.edited_at) and
        ms.is_draft == false and
        t.patient_id in ^connected_patients_ids
    )
    |> preload([_ms, p, t], procedures: p, timeline: t)
    |> where(^Postgres.Option.next_token(params, :inserted_at, :desc))
    |> order_by(desc: :inserted_at)
    |> Repo.fetch_paginated(params, :inserted_at)
  end

  def encode_next_token(nil), do: nil
  def encode_next_token(naive_date_time), do: NaiveDateTime.to_iso8601(naive_date_time)

  def decode_next_token(%{"next_token" => next_token} = params) when not is_nil(next_token) do
    Map.update!(params, "next_token", &NaiveDateTime.from_iso8601!/1)
  end

  def decode_next_token(params), do: params
end
