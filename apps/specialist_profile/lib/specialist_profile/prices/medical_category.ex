defmodule SpecialistProfile.Prices.MedicalCategory do
  use Postgres.Schema
  use Postgres.Service

  schema "medical_categories" do
    field :name, :string
    field :image_url, :string
  end
end
