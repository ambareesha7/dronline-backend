defmodule EMR.SpecialistData do
  use Postgres.Schema
  use Postgres.Service

  alias __MODULE__

  defmodule Specialist do
    use Postgres.Schema

    schema "specialists" do
      field :email, :string
      field :type, :string
    end
  end

  schema "specialist_basic_infos" do
    field :image_url, :string
    field :last_name, :string

    belongs_to :specialist, Specialist
  end

  @spec fetch_by_id(pos_integer) :: {:ok, %SpecialistData{}} | {:error, :not_found}
  def fetch_by_id(specialist_id) do
    SpecialistData
    |> join(:inner, [sd], s in assoc(sd, :specialist))
    |> where(specialist_id: ^specialist_id)
    |> preload([_sd, s], specialist: s)
    |> Repo.fetch_one()
  end
end
