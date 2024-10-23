defmodule Membership.Specialists do
  use Postgres.Service

  defmodule BasicInfo do
    use Postgres.Schema

    schema "specialist_basic_infos" do
      field :first_name, :string
      field :last_name, :string
    end
  end

  defmodule Location do
    use Postgres.Schema

    schema "specialist_locations" do
      field :street, :string
      field :number, :string
      field :city, :string
      field :country, :string
    end
  end

  defmodule Specialist do
    use Postgres.Schema

    schema "specialists" do
      field :email, :string
      field :package_type, :string
      field :trial_ends_at, :naive_datetime

      has_one :basic_info, Membership.Specialists.BasicInfo
      has_one :location, Membership.Specialists.Location
    end
  end

  @spec fetch_by_id(pos_integer) :: {:ok, map}
  def fetch_by_id(id) do
    Specialist
    |> where(id: ^id)
    |> join(:inner, [s], bi in assoc(s, :basic_info))
    |> join(:inner, [s], l in assoc(s, :location))
    |> preload([s, bi, l], basic_info: bi, location: l)
    |> Repo.fetch_one()
    |> case do
      {:ok, result} ->
        {:ok, parse_result(result)}

      error ->
        error
    end
  end

  @spec end_active_trial(pos_integer) :: {:ok, map}
  def end_active_trial(id) do
    specialist = %Specialist{trial_ends_at: trial_ends_at} = Repo.get_by(Specialist, id: id)

    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    case NaiveDateTime.compare(now, trial_ends_at) do
      :lt ->
        specialist
        |> Ecto.Changeset.change(%{trial_ends_at: now})
        |> Repo.update()

      _ ->
        {:ok, nil}
    end
  end

  defp parse_result(%Specialist{} = specialist) do
    %{
      city: specialist.location.city,
      country: specialist.location.country,
      email: specialist.email,
      first_name: specialist.basic_info.first_name,
      id: specialist.id,
      last_name: specialist.basic_info.last_name,
      number: specialist.location.number,
      street: specialist.location.street
    }
  end
end
