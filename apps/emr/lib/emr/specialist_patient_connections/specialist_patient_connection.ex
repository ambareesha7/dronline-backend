defmodule EMR.SpecialistPatientConnections.SpecialistPatientConnection do
  use Postgres.Schema
  use Postgres.Service

  alias __MODULE__

  defmodule Timeline do
    use Postgres.Schema

    schema "timelines" do
      field(:patient_id, :integer)
    end
  end

  schema "specialist_patient_connections" do
    field(:specialist_id, :integer)
    field(:patient_id, :integer)
    field(:team_id, :integer)

    belongs_to(:timeline, Timeline,
      references: :patient_id,
      foreign_key: :patient_id,
      define_field: false
    )

    timestamps()
  end

  @spec create(pos_integer, pos_integer) ::
          {:ok, %SpecialistPatientConnection{}} | {:error, Ecto.Changeset.t()}
  def create(specialist_id, patient_id) do
    team_id = Teams.specialist_team_id(specialist_id)

    %SpecialistPatientConnection{
      specialist_id: specialist_id,
      patient_id: patient_id,
      team_id: team_id
    }
    |> Repo.insert(returning: true, on_conflict: :nothing)
  end

  @spec connect_to_team(pos_integer(), pos_integer()) :: :ok
  def connect_to_team(specialist_id, team_id) do
    SpecialistPatientConnection
    |> where(specialist_id: ^specialist_id)
    |> Repo.update_all(set: [team_id: team_id])

    :ok
  end

  @spec specialist_patient_connected?(pos_integer, pos_integer, boolean) :: boolean
  def specialist_patient_connected?(specialist_id, param_id, via_timeline \\ false)

  def specialist_patient_connected?(specialist_id, timeline_id, true) do
    SpecialistPatientConnection
    |> join(:inner, [spc], t in assoc(spc, :timeline))
    |> where([spc, t], spc.specialist_id == ^specialist_id and t.id == ^timeline_id)
    |> Repo.fetch_one()
    |> case do
      {:ok, _specialist_patient_connection} -> true
      {:error, :not_found} -> false
    end
  end

  def specialist_patient_connected?(specialist_id, patient_id, false) do
    SpecialistPatientConnection
    |> where(specialist_id: ^specialist_id, patient_id: ^patient_id)
    |> Repo.fetch_one()
    |> case do
      {:ok, _specialist_patient_connection} -> true
      {:error, :not_found} -> false
    end
  end

  @spec fetch_patient_specialists_ids(pos_integer) :: {:ok, list(pos_integer)}
  def fetch_patient_specialists_ids(patient_id) do
    SpecialistPatientConnection
    |> where(patient_id: ^patient_id)
    |> select([connection], connection.specialist_id)
    |> Repo.fetch_all()
  end
end
