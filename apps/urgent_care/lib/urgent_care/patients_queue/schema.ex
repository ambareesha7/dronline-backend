defmodule UrgentCare.PatientsQueue.Schema do
  use Postgres.Schema
  use Postgres.Service

  alias Postgres.Repo

  import Ecto.Changeset
  import Ecto.Query

  @fields [:handling_team_ids, :patient_id, :record_id, :device_id]

  schema "patients_queue" do
    field :handling_team_ids, {:array, :integer}
    field :patient_id, :integer
    field :record_id, :integer
    field :device_id, :string

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> validate_length(:handling_team_ids, min: 1)
  end

  def fetch_by_team_id(team_id) do
    __MODULE__
    |> where([pq], ^team_id in pq.handling_team_ids)
    |> order_by(asc: :inserted_at)
    |> Repo.fetch_all()
  end

  def fetch_by_patient_id(patient_id) do
    if is_nil(patient_id) do
      nil
    else
      __MODULE__
      |> where([pq], ^patient_id == pq.patient_id)
      |> Repo.one()
    end
  end
end
