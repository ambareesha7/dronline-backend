defmodule Triage.Vitals do
  use Postgres.Schema
  use Postgres.Service

  alias __MODULE__

  schema "vitals" do
    field :weight, :integer
    field :height, :integer

    field :systolic, :integer
    field :diastolic, :integer
    field :pulse, :integer

    field :ekg_file_url, :string

    field :timeline_id, :integer
    field :patient_id, :integer
    field :nurse_id, :integer

    timestamps()
  end

  @fields [:diastolic, :ekg_file_url, :height, :pulse, :systolic, :weight]
  defp changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
  end

  @spec fetch_by_id(pos_integer) :: {:ok, %Vitals{}} | {:error, :not_found}
  defp fetch_by_id(vitals_id) do
    Vitals
    |> where(id: ^vitals_id)
    |> Repo.fetch_one()
  end

  @spec create(pos_integer, pos_integer, pos_integer, map) ::
          {:ok, %Vitals{}} | {:error, Ecto.Changeset.t()}
  def create(patient_id, timeline_id, nurse_id, params) do
    %Vitals{timeline_id: timeline_id, patient_id: patient_id, nurse_id: nurse_id}
    |> changeset(params)
    |> Repo.insert()
  end

  @spec update(pos_integer, map) :: {:ok, %Vitals{}} | {:error, Ecto.Changeset.t()}
  def update(vitals_id, params) do
    {:ok, vitals} = fetch_by_id(vitals_id)

    vitals
    |> changeset(params)
    |> Repo.update()
  end

  # TODO vitals are part of record and should be moved to better place
  @doc """
  Fetches paginated vitals that contain bmi data for given record
  """
  @spec fetch_bmi_entries_for_record(pos_integer, pos_integer, map) ::
          {:ok, [%__MODULE__{}], next_token :: pos_integer | nil}
  def fetch_bmi_entries_for_record(patient_id, record_id, params) do
    __MODULE__
    |> where(patient_id: ^patient_id)
    |> where(timeline_id: ^record_id)
    |> where(^Postgres.Option.next_token(params, :id, :desc))
    |> where([v], v.weight > 0)
    |> order_by(desc: :id)
    |> Repo.fetch_paginated(params, :id)
  end

  @doc """
  Fetches paginated vitals that contain blood pressure data for given record
  """
  @spec fetch_blood_pressure_entries_for_record(pos_integer, pos_integer, map) ::
          {:ok, [%__MODULE__{}], next_token :: pos_integer | nil}
  def fetch_blood_pressure_entries_for_record(patient_id, record_id, params) do
    __MODULE__
    |> where(patient_id: ^patient_id)
    |> where(timeline_id: ^record_id)
    |> where(^Postgres.Option.next_token(params, :id, :desc))
    |> where([v], v.pulse > 0)
    |> order_by(desc: :id)
    |> Repo.fetch_paginated(params, :id)
  end
end
