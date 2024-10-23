defmodule Visits.UploadedDocuments do
  use Postgres.Schema
  use Postgres.Service

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @fields [:patient_id, :document_url, :record_id]

  schema "visits_uploaded_documents" do
    field :patient_id, :integer
    field :record_id, :integer
    field :document_url, :string

    timestamps()
  end

  def create(params) do
    %__MODULE__{}
    |> changeset(params)
    |> Repo.insert()
  end

  @spec by_record(integer()) :: {:ok, list(__MODULE__)}
  def by_record(record_id) do
    __MODULE__
    |> where(record_id: ^record_id)
    |> Repo.fetch_all()
  end

  @spec by_record_and_patient(integer(), integer()) :: {:ok, list(__MODULE__)}
  def by_record_and_patient(record_id, patient_id) do
    __MODULE__
    |> where(record_id: ^record_id)
    |> where(patient_id: ^patient_id)
    |> Repo.fetch_all()
  end

  defp changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
  end
end
