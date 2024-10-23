defmodule EMR.PatientRecords.PatientRecord do
  use Postgres.Schema
  use Postgres.Service

  alias EMR.PatientRecords.PatientRecord
  alias Insurance.Accounts.Account
  alias Insurance.Accounts.Patient

  schema "timelines" do
    field :active, :boolean
    field :closed_at, :naive_datetime_usec
    field :canceled_at, :naive_datetime_usec
    field :created_by_specialist_id, :integer
    field :with_specialist_id, :integer
    field :us_board_request_id, :string
    field :patient_id, :integer

    field :type, Ecto.Enum, values: [:MANUAL, :CALL, :AUTO, :VISIT, :US_BOARD, :IN_OFFICE]

    belongs_to :insurance_account, Account

    timestamps()
  end

  @doc """
  Returns specialist_ids of specialist who created the record and with whom record was created
  """
  @spec get_main_specialist_ids(%__MODULE__{}) :: [pos_integer]
  def get_main_specialist_ids(record) do
    [record.created_by_specialist_id, record.with_specialist_id]
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

  @fields [:created_by_specialist_id, :patient_id, :with_specialist_id]
  defp manual_record_changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> validate_number(:patient_id, greater_than: 0)
    |> put_change(:type, :MANUAL)
    |> unique_constraint(:_manual_record_limit,
      name: "current_manual_timeline_index",
      message: "you can have only one active record per patient"
    )
  end

  @fields [:patient_id, :with_specialist_id]
  defp call_record_changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> validate_number(:patient_id, greater_than: 0)
    |> put_change(:type, :CALL)
  end

  @fields [:patient_id]
  defp automatic_record_changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> validate_number(:patient_id, greater_than: 0)
    |> put_change(:type, :AUTO)
  end

  @fields [:patient_id, :with_specialist_id]
  defp visit_record_changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> validate_number(:patient_id, greater_than: 0)
    |> put_change(:type, :VISIT)
  end

  @fields [:patient_id, :with_specialist_id, :us_board_request_id]
  defp us_board_record_changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> validate_number(:patient_id, greater_than: 0)
    |> put_change(:type, :US_BOARD)
  end

  @fields [:patient_id, :with_specialist_id]
  defp in_office_record_changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> validate_number(:patient_id, greater_than: 0)
    |> put_change(:type, :IN_OFFICE)
  end

  @spec create_manual_record(pos_integer, pos_integer) ::
          {:ok, %PatientRecord{}}
          | {:error, Ecto.Changeset.t()}
  def create_manual_record(patient_id, created_by_specialist_id) do
    %__MODULE__{}
    |> manual_record_changeset(%{
      patient_id: patient_id,
      created_by_specialist_id: created_by_specialist_id,
      with_specialist_id: created_by_specialist_id
    })
    |> assign_insurance_account(patient_id)
    |> Repo.insert()
  end

  @spec create_visit_record(pos_integer, pos_integer) ::
          {:ok, %PatientRecord{}}
          | {:error, Ecto.Changeset.t()}
  def create_visit_record(patient_id, with_specialist_id) do
    %__MODULE__{}
    |> visit_record_changeset(%{patient_id: patient_id, with_specialist_id: with_specialist_id})
    |> assign_insurance_account(patient_id)
    |> Repo.insert()
  end

  @spec create_us_board_record(pos_integer, pos_integer, String.t()) ::
          {:ok, %PatientRecord{}}
          | {:error, Ecto.Changeset.t()}
  def create_us_board_record(patient_id, with_specialist_id, us_board_request_id) do
    %__MODULE__{}
    |> us_board_record_changeset(%{
      patient_id: patient_id,
      with_specialist_id: with_specialist_id,
      us_board_request_id: us_board_request_id
    })
    |> assign_insurance_account(patient_id)
    |> unique_constraint([:patient_id, :us_board_request_id],
      name: "unique_status_call_scheduled_second_opinion_index"
    )
    |> Repo.insert()
  end

  @spec create_in_office_record(pos_integer, pos_integer) ::
          {:ok, %PatientRecord{}}
          | {:error, Ecto.Changeset.t()}
  def create_in_office_record(patient_id, with_specialist_id) do
    %__MODULE__{}
    |> in_office_record_changeset(%{
      patient_id: patient_id,
      with_specialist_id: with_specialist_id
    })
    |> assign_insurance_account(patient_id)
    |> Repo.insert()
  end

  @spec create_call_record(pos_integer, pos_integer) ::
          {:ok, %PatientRecord{}}
          | {:error, Ecto.Changeset.t()}
  def create_call_record(patient_id, with_specialist_id) do
    %__MODULE__{}
    |> call_record_changeset(%{
      patient_id: patient_id,
      with_specialist_id: with_specialist_id
    })
    |> assign_insurance_account(patient_id)
    |> Repo.insert()
  end

  @doc """
  Fetches current manual record for given patient_id or creates new one
  """
  @spec fetch_or_create_automatic(non_neg_integer | any) ::
          {:ok, %PatientRecord{}} | {:error, Ecto.Changeset.t()}
  def fetch_or_create_automatic(patient_id) when is_integer(patient_id) do
    case fetch_automatic(patient_id) do
      {:ok, %PatientRecord{} = record} ->
        {:ok, record}

      {:error, :not_found} ->
        create_automatic(patient_id)
    end
  end

  def fetch_or_create_automatic(_) do
    {:error, "patient_id must be an integer"}
  end

  @spec fetch_automatic(non_neg_integer) :: {:ok, %PatientRecord{}} | {:error, :not_found}
  defp fetch_automatic(patient_id) do
    PatientRecord
    |> where(patient_id: ^patient_id, active: true, type: :AUTO)
    |> Repo.fetch_one()
  end

  @spec create_automatic(non_neg_integer) :: {:ok, %PatientRecord{}}
  defp create_automatic(patient_id) do
    {:ok, %PatientRecord{}} =
      %PatientRecord{}
      |> automatic_record_changeset(%{patient_id: patient_id})
      |> assign_insurance_account(patient_id)
      |> unique_constraint(:user_id, name: :current_auto_timeline_index)
      |> Repo.insert()
  end

  @spec fetch(pos_integer, map) :: {:ok, [%PatientRecord{}], next_token :: pos_integer | nil}
  def fetch(patient_id, params) do
    PatientRecord
    |> where(patient_id: ^patient_id)
    |> where(^Postgres.Option.next_token(params, :id, :desc))
    |> status_filter(params)
    |> order_by(desc: :id)
    |> Repo.fetch_paginated(params, :id)
  end

  @spec fetch_by_id(pos_integer, pos_integer) :: {:ok, %PatientRecord{}} | {:error, :not_found}
  def fetch_by_id(record_id, patient_id) do
    PatientRecord
    |> where(id: ^record_id, patient_id: ^patient_id)
    |> preload(insurance_account: :insurance_provider)
    |> Repo.fetch_one()
  end

  defp status_filter(query, %{"status" => "ONGOING"}) do
    query |> where([q], q.active == true)
  end

  defp status_filter(query, %{"status" => "ENDED"}) do
    query |> where([q], q.active == false and not is_nil(q.closed_at))
  end

  defp status_filter(query, _params) do
    query
  end

  @spec close(pos_integer, pos_integer) :: :ok | {:error, :not_found}
  def close(patient_id, record_id) do
    PatientRecord
    |> where(patient_id: ^patient_id, id: ^record_id)
    |> update([pr],
      set: [
        active: false,
        closed_at: fragment("COALESCE(?, ?)", pr.closed_at, ^DateTime.utc_now()),
        updated_at: ^DateTime.utc_now()
      ]
    )
    |> Repo.update_all([])
    |> case do
      {1, _} -> :ok
      _ -> {:error, :not_found}
    end
  end

  @spec cancel(pos_integer, pos_integer) :: :ok
  def cancel(patient_id, record_id) do
    PatientRecord
    |> where(patient_id: ^patient_id, id: ^record_id)
    |> update([pr],
      set: [
        active: false,
        canceled_at: ^DateTime.utc_now(),
        updated_at: ^DateTime.utc_now()
      ]
    )
    |> Repo.update_all([])

    :ok
  end

  @spec set_with_whom_value(pos_integer, pos_integer, pos_integer) :: :ok
  def set_with_whom_value(patient_id, record_id, with_specialist_id) do
    PatientRecord
    |> where(patient_id: ^patient_id, id: ^record_id, type: :AUTO)
    |> update([pr],
      set: [
        with_specialist_id: fragment("COALESCE(?, ?)", pr.with_specialist_id, ^with_specialist_id)
      ]
    )
    |> Repo.update_all([])

    :ok
  end

  defp assign_insurance_account(changeset, patient_id) do
    patient = Repo.get_by(Patient, id: patient_id)

    do_assign_insurance_account(changeset, patient)
  end

  # nil patient is only for tests
  defp do_assign_insurance_account(changeset, nil), do: changeset

  defp do_assign_insurance_account(changeset, %Patient{insurance_account_id: account_id}) do
    changeset
    |> put_change(:insurance_account_id, account_id)
  end
end
