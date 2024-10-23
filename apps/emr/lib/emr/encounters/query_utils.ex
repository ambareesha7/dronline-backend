defmodule EMR.Encounters.QueryUtils do
  use Postgres.Service

  alias EMR.PatientRecords.PatientRecord

  @spec query() :: Ecto.Query.t()
  def query do
    PatientRecord
    |> join(:left, [r], v in "visits_log", on: v.record_id == r.id)
  end

  @spec filter(Ecto.Query.t(), Keyword.t()) :: Ecto.Query.t()
  def filter(query, filters) do
    specialist_id = filters[:specialist_id]
    specialist_ids = filters[:specialist_ids]
    type_filter = filters[:type_filter]
    state_filter = filters[:state_filter]
    day_filter = filters[:day_filter]

    query
    |> filter_by_specialist(specialist_id)
    |> filter_by_specialists(specialist_ids)
    |> filter_by_type(type_filter)
    |> filter_by_state(state_filter)
    |> filter_by_day(day_filter)
  end

  defp filter_by_specialist(query, nil), do: query

  defp filter_by_specialist(query, specialist_id) do
    query
    |> where(with_specialist_id: ^specialist_id)
  end

  defp filter_by_specialists(query, nil), do: query

  defp filter_by_specialists(query, specialist_ids) do
    query
    |> where([r], r.with_specialist_id in ^specialist_ids)
  end

  defp filter_by_type(query, nil), do: query
  defp filter_by_type(query, "UNKNOWN_TYPE"), do: query

  defp filter_by_type(query, types) when is_list(types) do
    query
    |> where([r], r.type in ^types)
  end

  defp filter_by_type(query, type) do
    query
    |> where([r], r.type == ^type)
  end

  defp filter_by_state(query, nil), do: query
  defp filter_by_state(query, "UNKNOWN_STATE"), do: query

  defp filter_by_state(query, "CANCELED") do
    query
    |> where([r], r.active == false and not is_nil(r.canceled_at))
  end

  defp filter_by_state(query, "COMPLETED") do
    query
    |> where([r], r.active == false and not is_nil(r.closed_at))
  end

  defp filter_by_state(query, "PENDING") do
    query
    |> where([r], r.active == true)
  end

  defp filter_by_day(query, nil), do: query

  defp filter_by_day(query, day_start) do
    seconds_in_a_day = 24 * 60 * 60
    next_day_start = day_start + seconds_in_a_day

    query
    |> where(
      [_r, v],
      not is_nil(v) and
        v.start_time >= ^day_start and
        v.start_time < ^next_day_start
    )
  end
end
