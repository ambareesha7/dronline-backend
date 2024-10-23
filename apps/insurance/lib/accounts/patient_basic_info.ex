defmodule Insurance.Accounts.PatientBasicInfo do
  use Postgres.Schema
  use Postgres.Service

  schema "patient_basic_infos" do
    field :is_insured, :boolean
    field :insurance_provider_name, :string
    field :insurance_member_id, :string

    field :patient_id, :integer

    timestamps()
  end
end
