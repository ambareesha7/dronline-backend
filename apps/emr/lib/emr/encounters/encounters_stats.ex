defmodule EMR.Encounters.EncountersStats do
  use Postgres.Service

  alias EMR.Encounters.QueryUtils

  @type stats :: %{
          pending: number,
          completed: number,
          canceled: number,
          scheduled: number
        }

  @type urgent_care_stats :: %{
          total: number
        }

  @spec get_for_specialist(non_neg_integer()) :: stats
  def get_for_specialist(specialist_id) do
    params = [specialist_id: specialist_id]

    %{
      pending: pending_encounters_count(params),
      completed: completed_encounters_count(params),
      canceled: canceled_encounters_count(params),
      scheduled: scheduled_encounters_count(params)
    }
  end

  @spec get_for_team(non_neg_integer()) :: stats
  def get_for_team(team_id) do
    specialist_ids =
      team_id
      |> Teams.get_members()
      |> Enum.map(& &1.specialist_id)

    params = [specialist_ids: specialist_ids]

    %{
      pending: pending_encounters_count(params),
      completed: completed_encounters_count(params),
      canceled: canceled_encounters_count(params),
      scheduled: scheduled_encounters_count(params)
    }
  end

  @spec get_urgent_care_stats_for_team(non_neg_integer()) :: urgent_care_stats
  def get_urgent_care_stats_for_team(team_id) do
    specialist_ids =
      team_id
      |> Teams.get_members()
      |> Enum.map(& &1.specialist_id)

    params = [specialist_ids: specialist_ids]

    %{
      total: urgent_care_encounters_count(params)
    }
  end

  defp pending_encounters_count(params) do
    QueryUtils.query()
    |> QueryUtils.filter(Keyword.merge(params, state_filter: "PENDING"))
    |> fetch_one()
  end

  defp completed_encounters_count(params) do
    QueryUtils.query()
    |> QueryUtils.filter(Keyword.merge(params, state_filter: "COMPLETED"))
    |> fetch_one()
  end

  defp canceled_encounters_count(params) do
    QueryUtils.query()
    |> QueryUtils.filter(Keyword.merge(params, state_filter: "CANCELED"))
    |> fetch_one()
  end

  defp scheduled_encounters_count(params) do
    QueryUtils.query()
    |> QueryUtils.filter(Keyword.merge(params, type_filter: ["VISIT", "IN_OFFICE", "US_BOARD"]))
    |> fetch_one()
  end

  defp urgent_care_encounters_count(params) do
    QueryUtils.query()
    |> QueryUtils.filter(Keyword.merge(params, type_filter: "AUTO"))
    |> fetch_one()
  end

  defp fetch_one(query) do
    query
    |> select([r], count(r.id))
    |> Repo.one()
  end
end
