defmodule SpecialistProfile.Specialists do
  use Postgres.Schema
  use Postgres.Service

  @spec fetch_all(map) :: {:ok, [pos_integer], String.t()}
  def fetch_all(params) do
    {:ok, result, next_token} =
      params
      |> specialists()
      |> select([s], s.id)
      |> Repo.fetch_paginated(params)

    {:ok, result, to_string(next_token)}
  end

  @spec fetch_online(map, [pos_integer]) :: {:ok, [pos_integer], String.t()}
  def fetch_online(params, online_ids) do
    {:ok, result, next_token} =
      params
      |> specialists()
      |> where([s], s.id in ^online_ids)
      |> select([s], s.id)
      |> Repo.fetch_paginated(params)

    {:ok, result, to_string(next_token)}
  end

  @spec search(map) :: {:ok, [pos_integer], String.t()}
  def search(params) do
    {:ok, result, next_token} =
      SpecialistProfile.Specialist
      |> Postgres.TSQuery.filter(params["filter"],
        join: "specialist_search_datas",
        on: :specialist_id
      )
      |> where([s], s.approval_status == "VERIFIED")
      |> where(^Postgres.Option.next_token(params, :id))
      |> order_by(asc: :id)
      |> select([s], s.id)
      |> Repo.fetch_paginated(params)

    {:ok, result, to_string(next_token)}
  end

  defp specialists(params) do
    SpecialistProfile.Specialist
    |> Postgres.TSQuery.filter(params["filter"],
      join: "doctor_filter_datas",
      on: :specialist_id
    )
    |> where([s], s.approval_status == "VERIFIED" and s.type == "EXTERNAL")
    |> where(^Postgres.Option.next_token(params, :id))
    |> filter_by_membership(params)
    |> order_by(asc: :id)
  end

  defp filter_by_membership(query, %{"membership" => membership}) when membership != "" do
    query
    |> where([s], s.package_type == ^membership)
  end

  defp filter_by_membership(query, _params), do: query
end
