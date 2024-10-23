defmodule Insurance.Accounts.Patient do
  use Postgres.Schema
  use Postgres.Service

  schema "patients" do
    field :phone_number, :string
    field :insurance_account_id, :integer

    timestamps()
  end
end
