defmodule EMR.Tests do
  use Postgres.Service

  alias EMR.PatientsList
  alias EMR.Tests.OrderedTest

  @spec get_for_specialist(pos_integer, map) ::
          {:ok, [%OrderedTest{}], next_token :: pos_integer | nil}
  def get_for_specialist(specialist_id, params) do
    connected_patients_ids = PatientsList.fetch_ids(specialist_id)

    EMR.Tests.OrderedTestsBundle
    |> join(:inner, [tb], t in assoc(tb, :tests))
    |> join(:inner, [_tb, t], mt in assoc(t, :medical_test))
    |> join(:inner, [_tb, _t, mt], mtc in assoc(mt, :medical_tests_category))
    |> preload([_tb, t, mt, mtc],
      tests: {t, medical_test: {mt, medical_tests_category: mtc}}
    )
    |> where([tb], tb.patient_id in ^connected_patients_ids)
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
