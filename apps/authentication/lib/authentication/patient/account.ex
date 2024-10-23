defmodule Authentication.Patient.Account do
  @moduledoc """
  Account can be created:
  - by the patient, when they sign up using firebase through a mobile app. Then, `is_signed_up: true`.
  - automatically, when they use Urgent Care on web. Then, their number is not verified and they don't fill in all Basic Info.
    Then, `is_signed_up: false`.
  """
  use Postgres.Schema
  use Postgres.Service

  schema "patient_accounts" do
    field :firebase_id, :string
    field :phone_number, :string

    field :main_patient_id, :integer

    # is_signed_up: false - when account is created automatically, without user signing up
    field :is_signed_up, :boolean, default: true

    timestamps()
  end

  @fields [:firebase_id, :main_patient_id, :phone_number, :is_signed_up]
  @required_fields [:main_patient_id, :phone_number]

  @spec create(map) :: {:ok, %__MODULE__{}} | {:error, Ecto.Changeset.t()}
  def create(params) do
    %__MODULE__{}
    |> cast(params, @fields)
    |> validate_format(:phone_number, ~r/\+\d+/)
    |> validate_required(@required_fields)
    |> Repo.insert()
  end

  @spec get_by_firebase_id(String.t()) :: %__MODULE__{} | nil
  def get_by_firebase_id(firebase_id) do
    Repo.get_by(__MODULE__, firebase_id: firebase_id)
  end

  @spec get_by_phone_number(String.t()) :: %__MODULE__{} | nil
  def get_by_phone_number(phone_number) do
    Repo.get_by(__MODULE__, phone_number: phone_number)
  end

  def fetch_all_by_main_patient_ids(main_patient_ids) do
    {:ok, accounts} =
      __MODULE__ |> where([pa], pa.main_patient_id in ^main_patient_ids) |> Repo.fetch_all()

    accounts
  end
end
