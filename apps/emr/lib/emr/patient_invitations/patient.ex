defmodule EMR.PatientInvitations.Patient do
  use Postgres.Schema
  use Postgres.Service

  schema "patients" do
    field :phone_number, :string
  end

  def fetch_by_id(id) do
    __MODULE__
    |> where(id: ^id)
    |> Repo.fetch_one()
  end
end
