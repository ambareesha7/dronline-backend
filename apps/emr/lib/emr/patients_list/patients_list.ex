defmodule EMR.PatientsList do
  alias EMR.SpecialistPatientConnections.SpecialistPatientConnection

  defmodule Patient do
    use Postgres.Schema

    schema "patients" do
      field(:onboarding_completed, :boolean)

      has_many(:specialist_patient_connections, SpecialistPatientConnection)
    end
  end

  use Postgres.Service

  @doc """
  Fetches all patients
  """
  @spec fetch(non_neg_integer(), map) :: {:ok, [%Patient{}], next_token :: pos_integer | nil}
  def fetch(specialist_id, params) do
    Patient
    |> visible_by(specialist_id)
    |> Postgres.TSQuery.filter(params["filter"],
      join: "patient_filter_datas",
      on: :patient_id
    )
    |> where([p], p.onboarding_completed)
    |> where(^Postgres.Option.next_token(params, :id))
    |> order_by(asc: :id)
    |> Repo.fetch_paginated(params, :id)
  end

  @doc """
  Fetches all patients ids
  """
  @spec fetch_ids(non_neg_integer()) :: [non_neg_integer()]
  def fetch_ids(specialist_id) do
    Patient
    |> visible_by(specialist_id)
    |> where([p], p.onboarding_completed)
    |> select([p], p.id)
    |> Repo.all()
  end

  @doc """
  Fetches patients who are connected to given specialist
  """
  @spec fetch_connected(pos_integer, map) ::
          {:ok, [%Patient{}], next_token :: pos_integer | nil}
  def fetch_connected(specialist_id, params) do
    Patient
    |> connected_to_specific_specialist(specialist_id)
    |> Postgres.TSQuery.filter(params["filter"],
      join: "patient_filter_datas",
      on: :patient_id
    )
    |> where(^Postgres.Option.next_token(params, :id))
    |> order_by(asc: :id)
    |> Repo.fetch_paginated(params, :id)
  end

  defp visible_by(query, specialist_id) do
    case Teams.specialist_team_id(specialist_id) do
      nil ->
        connected_to_specific_specialist(query, specialist_id)

      team_id ->
        connected_to_any_specialist_from_the_team(query, team_id)
    end
  end

  defp connected_to_specific_specialist(query, specialist_id) do
    query
    |> join(:inner, [p], spc in assoc(p, :specialist_patient_connections))
    |> where([_p, spc], spc.specialist_id == ^specialist_id)
  end

  defp connected_to_any_specialist_from_the_team(query, team_id) do
    query
    |> join(:inner, [p], spc in assoc(p, :specialist_patient_connections))
    |> where([_p, spc], spc.team_id == ^team_id)
  end
end
