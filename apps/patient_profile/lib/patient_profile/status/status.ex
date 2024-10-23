defmodule PatientProfile.Status do
  use Postgres.Schema
  use Postgres.Service

  alias __MODULE__

  schema "patients" do
    field :onboarding_completed, :boolean
  end

  @doc """
  Fetches patient status flags by patient_id
  """
  @spec fetch_by_patient_id(String.t()) :: {:ok, %Status{}}
  def fetch_by_patient_id(patient_id) do
    Repo.fetch(Status, patient_id)
  end
end
