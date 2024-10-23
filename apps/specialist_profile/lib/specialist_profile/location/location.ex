defmodule SpecialistProfile.Location do
  use Postgres.Schema
  use Postgres.Service

  alias __MODULE__
  alias Ecto.Multi
  alias SpecialistProfile.Status

  schema "specialist_locations" do
    field(:additional_numbers, :string)
    field(:city, :string)
    field(:country, :string)
    field(:neighborhood, :string)
    field(:number, :string)
    field(:postal_code, :string)
    field(:street, :string)
    field(:formatted_address, :string)
    field(:coordinates, Geo.PostGIS.Geometry)

    field(:specialist_id, :integer)

    timestamps()
  end

  @fields [
    :city,
    :country,
    :number,
    :neighborhood,
    :postal_code,
    :street,
    :formatted_address
  ]
  @required_fields [:country, :coordinates, :formatted_address]
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> put_coordinates(params)
    |> validate_required(@required_fields)
  end

  @doc """
  Fetches location of specialist for given specialist id
  """
  @spec fetch_by_specialist_id(pos_integer) :: {:ok, %Location{}}
  def fetch_by_specialist_id(specialist_id) do
    Location
    |> where(specialist_id: ^specialist_id)
    |> Repo.fetch_one()
    |> case do
      {:ok, location} -> {:ok, location}
      {:error, :not_found} -> {:ok, %Location{specialist_id: specialist_id}}
    end
  end

  @spec fetch_by_specialist_ids([pos_integer]) :: {:ok, [%__MODULE__{}]}
  def fetch_by_specialist_ids(specialist_ids) do
    __MODULE__
    |> where([bi], bi.specialist_id in ^specialist_ids)
    |> Repo.all()
  end

  @doc """
  Update location of specialist identified by given specialist id with passed params
  """
  @spec update(map, pos_integer) :: {:ok, %Location{}} | {:error, Ecto.Changeset.t()}
  def update(params, specialist_id) do
    Multi.new()
    |> Multi.run(:update_location, &update_location(&1, &2, specialist_id, params))
    |> Multi.run(:handle_onboarding_status, &handle_onboarding_status(&1, &2, specialist_id))
    |> Repo.transaction()
    |> case do
      {:ok, changes} ->
        {:ok, changes.update_location}

      {:error, _failed_operation, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  defp update_location(_repo, _multi, specialist_id, params) do
    {:ok, location} = fetch_by_specialist_id(specialist_id)

    location
    |> Location.changeset(params)
    |> Repo.insert_or_update()
  end

  defp handle_onboarding_status(_repo, _multi, specialist_id) do
    Status.handle_onboarding_status(specialist_id)

    {:ok, :handled}
  end

  defp put_coordinates(changeset, %{coordinates: %{lat: lat, lon: lon}}) do
    changeset
    |> put_change(
      :coordinates,
      %Geo.Point{
        coordinates: {lat, lon},
        srid: 4326
      }
    )
  end

  defp put_coordinates(changeset, _params), do: changeset
end
