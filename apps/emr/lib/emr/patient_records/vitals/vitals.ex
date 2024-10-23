defmodule EMR.PatientRecords.Vitals do
  use Postgres.Schema
  use Postgres.Service

  @behaviour EMR.PatientRecords.Timeline.ItemData

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "vitals_v2" do
    field :height, :integer
    field :weight, :integer

    field :blood_pressure_systolic, :integer
    field :blood_pressure_diastolic, :integer
    field :pulse, :integer

    field :respiratory_rate, :integer
    field :body_temperature, :float
    field :physical_exam, :string

    field :patient_id, :integer
    field :record_id, :integer

    field :provided_by_nurse_id, :integer

    timestamps()
  end

  @required_fields [
    :height,
    :weight,
    :blood_pressure_systolic,
    :blood_pressure_diastolic,
    :pulse,
    :respiratory_rate,
    :body_temperature,
    :physical_exam
  ]

  @spec add_newest(pos_integer, pos_integer, pos_integer, map) ::
          {:ok, %__MODULE__{}} | {:error, Ecto.Changeset.t()}
  def add_newest(patient_id, record_id, nurse_id, params)
      when is_integer(patient_id) and is_integer(record_id) and is_integer(nurse_id) do
    %__MODULE__{patient_id: patient_id, record_id: record_id, provided_by_nurse_id: nurse_id}
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> Repo.insert()
    |> case do
      {:ok, vitals} ->
        _ =
          EMR.PatientRecords.Timeline.Item.create_vitals_v2_item(patient_id, record_id, vitals.id)

        {:ok, vitals}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @spec get_latest(pos_integer) :: %__MODULE__{} | nil
  def get_latest(patient_id) when is_integer(patient_id) do
    __MODULE__
    |> where(patient_id: ^patient_id)
    |> order_by(desc: :inserted_at)
    |> limit(1)
    |> Repo.one()
  end

  @spec fetch_history(pos_integer, map) :: {:ok, [%__MODULE__{}], String.t()}
  def fetch_history(patient_id, params) when is_integer(patient_id) do
    {:ok, result, next_token} =
      __MODULE__
      |> where(patient_id: ^patient_id)
      |> where(^Postgres.Option.next_token(params, :inserted_at, :desc))
      |> order_by(desc: :inserted_at)
      |> Repo.fetch_paginated(params, :inserted_at)

    {:ok, result, parse_next_token(next_token)}
  end

  @spec fetch_history_for_record(pos_integer, pos_integer, map) ::
          {:ok, [%__MODULE__{}], String.t()}
  def fetch_history_for_record(patient_id, record_id, params)
      when is_integer(patient_id) and is_integer(record_id) do
    {:ok, result, next_token} =
      __MODULE__
      |> where(patient_id: ^patient_id)
      |> where(record_id: ^record_id)
      |> where(^Postgres.Option.next_token(params, :inserted_at, :desc))
      |> order_by(desc: :inserted_at)
      |> Repo.fetch_paginated(params, :inserted_at)

    {:ok, result, parse_next_token(next_token)}
  end

  defp parse_next_token(nil), do: ""
  defp parse_next_token(nt), do: NaiveDateTime.to_iso8601(nt)

  @impl true
  def specialist_ids_in_item(%__MODULE__{} = struct) do
    [struct.provided_by_nurse_id]
  end

  @impl true
  def display_name do
    "Provided Vitals"
  end
end
