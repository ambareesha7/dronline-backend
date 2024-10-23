defmodule Admin.USBoard.Specialist do
  use Postgres.Schema
  use Postgres.Service

  schema "specialist_basic_infos" do
    field :specialist_id, :integer
    field :title, :string
    field :first_name, :string
    field :last_name, :string
    field :image_url, :string
    field :phone_number, :string
    field :medical_title, :string, default: "UNKNOWN_MEDICAL_TITLE"

    timestamps()
  end
end
