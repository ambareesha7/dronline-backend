defmodule Admin.USBoard.Patient do
  use Postgres.Schema
  use Postgres.Service

  schema "patient_basic_infos" do
    field :patient_id, :integer
    field :birth_date, :date
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :title, :string

    timestamps()
  end
end
