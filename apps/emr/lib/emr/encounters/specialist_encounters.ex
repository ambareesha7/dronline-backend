defmodule EMR.Encounters.SpecialistEncounters do
  use Postgres.Service

  alias EMR.Encounters.QueryUtils

  def get(specialist_id, params) do
    type_filter = Map.get(params, "type_filter")
    state_filter = Map.get(params, "state_filter")
    day_filter = Map.get(params, "day_filter")
    params = decode_next_token(params)

    {:ok, result, next_token} =
      QueryUtils.query()
      |> QueryUtils.filter(
        specialist_id: specialist_id,
        type_filter: type_filter,
        state_filter: state_filter,
        day_filter: day_filter
      )
      |> join_call_recording()
      |> where(^Postgres.Option.next_token(params, :inserted_at, :desc))
      |> order_by(desc: :inserted_at)
      |> select()
      |> Repo.fetch_paginated(params, :inserted_at)

    {:ok, result, encode_next_token(next_token)}
  end

  def get_by_id(timeline_id) do
    QueryUtils.query()
    |> join_call_recording()
    |> where([r, v], r.id == ^timeline_id)
    |> select()
    |> Repo.one()
  end

  defp select(query) do
    query
    |> select([r, v, cr], %{
      id: r.id,
      patient_id: r.patient_id,
      type: r.type,
      state:
        fragment(
          """
            CASE WHEN ? = TRUE THEN 'PENDING'
                WHEN ? IS NOT NULL THEN 'COMPLETED'
                WHEN ? IS NOT NULL THEN 'CANCELED'
            END
          """,
          r.active,
          r.closed_at,
          r.canceled_at
        ),
      start_time:
        fragment(
          """
            CASE
              WHEN (? = 'VISIT' or ? = 'IN_OFFICE') THEN ?
              ELSE ?
            END
          """,
          r.type,
          r.type,
          v.start_time,
          cr.created_at
        ),
      # 900 seconds = 15 minutes (duration of a Visit)
      end_time:
        fragment(
          """
            CASE
              WHEN (? = 'VISIT' or ? = 'IN_OFFICE')  THEN COALESCE(?, 0) + 900
              ELSE ? + ?
            END
          """,
          r.type,
          r.type,
          v.start_time,
          cr.created_at,
          cr.duration
        ),
      # For pagination
      inserted_at: r.inserted_at,
      us_board_request_id: r.us_board_request_id
    })
  end

  defp join_call_recording(query) do
    query
    |> join(
      :left_lateral,
      [r, _v],
      rc in fragment(
        "SELECT * FROM call_recordings AS cr WHERE cr.record_id = ? ORDER BY cr.inserted_at LIMIT 1",
        r.id
      ),
      on: true
    )
  end

  defp encode_next_token(nil), do: nil
  defp encode_next_token(naive_date_time), do: NaiveDateTime.to_iso8601(naive_date_time)

  defp decode_next_token(%{"next_token" => next_token} = params) when not is_nil(next_token) do
    Map.update!(params, "next_token", &NaiveDateTime.from_iso8601!/1)
  end

  defp decode_next_token(params), do: params
end
