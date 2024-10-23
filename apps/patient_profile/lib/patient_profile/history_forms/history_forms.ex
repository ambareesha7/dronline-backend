defmodule PatientProfile.HistoryForms do
  use Postgres.Schema
  use Postgres.Service

  alias __MODULE__

  schema "patient_history_forms" do
    field :allergy, :binary
    field :family, :binary
    field :immunization, :binary
    field :medical, :binary
    field :social, :binary
    field :surgical, :binary

    field :patient_id, :integer

    timestamps()
  end

  @fields [:allergy, :family, :immunization, :medical, :social, :surgical]
  def changeset(struct, params \\ %{}) do
    struct |> cast(params, @fields, empty_values: [])
  end

  @doc """
  Fetches history forms based on patient_id.

  If patient doesn't have one yet then returns empty ones.
  """
  @spec fetch_by_patient_id(pos_integer) :: {:ok, %HistoryForms{}}
  def fetch_by_patient_id(patient_id) do
    HistoryForms
    |> where(patient_id: ^patient_id)
    |> Repo.fetch_one()
    |> case do
      {:ok, history_forms} -> {:ok, history_forms}
      {:error, :not_found} -> {:ok, %HistoryForms{patient_id: patient_id}}
    end
  end

  @doc """
  Creates new history forms or updates existing ones for given patient_id
  """
  @spec update(map, pos_integer) :: {:ok, %HistoryForms{}} | {:error, Ecto.Changeset.t()}
  def update(params, patient_id) do
    {:ok, history_forms} = fetch_by_patient_id(patient_id)

    history_forms
    |> changeset(params)
    |> Repo.insert_or_update()
  end
end
