defmodule Insurance.Accounts.Account do
  use Postgres.Schema
  use Postgres.Service

  alias Insurance.Providers.Provider

  schema "insurance_accounts" do
    field :patient_id, :integer
    field :member_id, :string

    belongs_to :insurance_provider,
               Provider,
               foreign_key: :provider_id

    timestamps()
  end
end
