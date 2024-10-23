defmodule Teams do
  alias EMR.SpecialistPatientConnections.SpecialistPatientConnection
  alias Postgres.Repo

  import Ecto.Query

  defmodule Team do
    use Postgres.Schema

    schema "specialist_teams" do
      field(:location, Geo.PostGIS.Geometry)
      field(:formatted_address, :string)
      field(:owner_id, :integer)
      field(:name, :string)
      field(:logo_url, :string)

      timestamps()
    end

    def changeset(struct, params) do
      cast(struct, params, __MODULE__.__schema__(:fields))
    end
  end

  defmodule TeamMember do
    use Postgres.Schema

    schema "specialist_team_members" do
      field(:team_id, :integer)
      field(:specialist_id, :integer)
      field(:role, :string)

      timestamps()
    end

    def changeset(struct, params) do
      struct
      |> cast(params, __MODULE__.__schema__(:fields))
      |> unique_constraint(:specialist_id)
      |> unique_constraint(:team_id_specialist_id)
    end
  end

  defmodule Invitation do
    use Postgres.Schema

    schema "team_invitations" do
      field(:team_id, :integer)
      field(:specialist_id, :integer)

      timestamps()
    end
  end

  defmodule SpecialistAddedToTeam do
    defstruct [:team_id, :specialist_id]
  end

  def get(id) do
    Team
    |> where([team], team.id == ^id)
    |> Repo.one()
  end

  @spec create_team(integer, map()) :: {:ok, %Team{}} | {:error, Ecto.Changeset.t()}
  def create_team(owner_id, params) do
    %Team{owner_id: owner_id}
    |> Team.changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, team} ->
        Repo.insert!(%TeamMember{
          team_id: team.id,
          specialist_id: owner_id,
          role: "admin"
        })

        {:ok, team}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec set_location(non_neg_integer(), map()) :: :ok
  def set_location(team_id, %{latitude: lat, longitude: lon} = params) do
    point = %Geo.Point{coordinates: {lat, lon}, srid: 4326}

    Team
    |> Repo.get(team_id)
    |> Team.changeset(%{location: point, formatted_address: params.formatted_address})
    |> Repo.update!()

    :ok
  end

  @spec set_branding(non_neg_integer(), map()) :: :ok
  def set_branding(team_id, %{name: name, logo_url: logo_url}) do
    Team
    |> Repo.get(team_id)
    |> Team.changeset(%{name: name, logo_url: logo_url})
    |> Repo.update!()

    :ok
  end

  @spec add_to_team(Keyword.t()) :: :ok
  def add_to_team(opts) do
    team_id = Keyword.fetch!(opts, :team_id)
    specialist_id = Keyword.fetch!(opts, :specialist_id)

    Repo.insert!(%Invitation{team_id: team_id, specialist_id: specialist_id},
      on_conflict: :replace_all,
      conflict_target: [:specialist_id, :team_id]
    )

    :ok
  end

  @spec get_invitations(non_neg_integer()) :: [%Invitation{}]
  def get_invitations(specialist_id) do
    Invitation
    |> where(specialist_id: ^specialist_id)
    |> join(:left, [i], t in Team, on: t.id == i.team_id)
    |> select([_invitation, team], team)
    |> Repo.all()
  end

  @spec accept_invitation(Keyword.t()) :: :ok | {:error, :already_in_a_team}
  def accept_invitation(opts) do
    team_id = Keyword.fetch!(opts, :team_id)
    specialist_id = Keyword.fetch!(opts, :specialist_id)

    :ok = delete_invitation(team_id, specialist_id)

    %TeamMember{}
    |> TeamMember.changeset(%{team_id: team_id, specialist_id: specialist_id, role: "member"})
    |> Repo.insert()
    |> case do
      {:ok, _} ->
        # TODO 13.06.2023 kinda hacky
        :ok = apply(SpecialistPatientConnection, :connect_to_team, [specialist_id, team_id])

      {:error, %Ecto.Changeset{errors: [team_id_specialist_id: _]}} ->
        :ok

      {:error, %Ecto.Changeset{errors: [specialist_id: _]}} ->
        {:error, :already_in_a_team}
    end
  end

  @spec decline_invitation(Keyword.t()) :: :ok
  def decline_invitation(opts) do
    team_id = Keyword.fetch!(opts, :team_id)
    specialist_id = Keyword.fetch!(opts, :specialist_id)

    :ok = delete_invitation(team_id, specialist_id)
  end

  @spec set_admin_role(non_neg_integer(), non_neg_integer()) :: :ok | {:error, :unauthorized}
  def set_admin_role(requester_id, member_id) do
    if is_owner?(requester_id) do
      TeamMember
      |> Repo.get_by(specialist_id: member_id)
      |> Ecto.Changeset.change(role: "admin")
      |> Repo.update!()

      :ok
    else
      {:error, :unauthorized}
    end
  end

  @spec revoke_admin_role(non_neg_integer(), non_neg_integer()) :: :ok | {:error, :unauthorized}
  def revoke_admin_role(requester_id, member_id) do
    if is_owner?(requester_id) do
      TeamMember
      |> Repo.get_by(specialist_id: member_id)
      |> Ecto.Changeset.change(role: "member")
      |> Repo.update!()

      :ok
    else
      {:error, :unauthorized}
    end
  end

  @spec remove_from_team(Keyword.t()) :: :ok
  def remove_from_team(opts) do
    team_id = Keyword.fetch!(opts, :team_id)
    specialist_id = Keyword.fetch!(opts, :specialist_id)

    TeamMember
    |> where(team_id: ^team_id)
    |> where(specialist_id: ^specialist_id)
    |> Repo.delete_all()

    :ok
  end

  @spec get_members(team_id :: pos_integer()) :: [%TeamMember{}]
  def get_members(team_id) do
    TeamMember
    |> where(team_id: ^team_id)
    |> Repo.all()
  end

  @spec specialist_team_id(pos_integer()) :: pos_integer() | nil
  def specialist_team_id(specialist_id) do
    TeamMember
    |> where(specialist_id: ^specialist_id)
    |> select([m], m.team_id)
    |> Repo.one()
  end

  @spec team_details(non_neg_integer()) :: map()
  def team_details(team_id) do
    team = Repo.get(Team, team_id)

    case team.location do
      nil ->
        Map.from_struct(team)

      %{coordinates: {lat, long}} ->
        team
        |> Map.merge(%{
          location: %{latitude: lat, longitude: long}
        })
        |> Map.from_struct()
    end
  end

  @spec teams_in_area(map(), list()) :: [%Team{}]
  def teams_in_area(%{latitude: lat, longitude: lon}, opts) do
    distance = Keyword.fetch!(opts, :distance_in_meters)

    Team
    |> where(
      [team],
      fragment(
        "ST_DWithin(?, ST_MakePoint(?, ?)::geography, ?)",
        team.location,
        ^lat,
        ^lon,
        ^distance
      )
    )
    |> Repo.all()
  end

  @spec is_admin?(non_neg_integer()) :: boolean()
  def is_admin?(specialist_id) do
    member = Repo.get_by(TeamMember, specialist_id: specialist_id, role: "admin")

    if member do
      true
    else
      false
    end
  end

  defp is_owner?(specialist_id) do
    team = Repo.get_by(Team, owner_id: specialist_id)

    if team do
      true
    else
      false
    end
  end

  defp delete_invitation(team_id, specialist_id) do
    Invitation
    |> where(team_id: ^team_id)
    |> where(specialist_id: ^specialist_id)
    |> Repo.delete_all()

    :ok
  end
end
