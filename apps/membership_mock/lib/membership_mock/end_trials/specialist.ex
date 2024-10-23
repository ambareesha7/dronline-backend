defmodule MembershipMock.EndTrials.Specialist do
  use Postgres.Schema
  use Postgres.Service

  schema "specialists" do
    field :trial_ends_at, :naive_datetime
    field :package_type, :string, default: "PLATINUM"
    field :type, :string, default: "EXTERNAL"
    field :email, :string
    field :password_hash, :string, default: "any"
    field :auth_token, :string

    timestamps()
  end
end
