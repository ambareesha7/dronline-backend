defmodule Visits.Specialists.Specialist do
  use Postgres.Schema
  use Postgres.Service

  schema "specialists" do
    field :email, :string
  end

  def fetch_by_specialist_id(specialist_id) do
    __MODULE__
    |> where(id: ^specialist_id)
    |> Repo.fetch_one()
  end
end
