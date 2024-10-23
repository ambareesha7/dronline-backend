defmodule Postgres.Seeds.Specialists do
  @moduledoc """
  Seed list of dev users.
  Every configuration field can be changed, except email,
  which is used as an identifier to do INSERT or UPDATE.
  """
  require Logger

  use Postgres.Schema
  use Postgres.Service

  alias Postgres.Seeds.Administrator
  alias Postgres.Seeds.BasicInfo
  alias Postgres.Seeds.MedicalCategory
  alias Postgres.Seeds.Specialist
  alias Postgres.Seeds.SpecialistLocation
  alias Postgres.Seeds.SpecialistsMedicalCategory
  alias Postgres.Seeds.Subscription
  alias Postgres.Seeds.Team
  alias Postgres.Seeds.TeamCredentials
  alias Postgres.Seeds.TeamMember

  @admin %{
    first_name: "Wesley",
    last_name: "Crusher",
    email_name: "admin",
    phone_number: "+1111111110",
    subscription_type: "BASIC",
    role: "member",
    type: "EXTERNAL",
    image_url:
      "https://storage.googleapis.com/dronline-prod/images/placeholders/default_man_avatar.png"
  }

  @team_owner %{
    first_name: "Jim",
    last_name: "Parsons",
    email_name: "gp",
    phone_number: "+1111111111",
    subscription_type: "BASIC",
    role: "admin",
    type: "GP"
  }

  @team_members [
    %{
      first_name: "Rick",
      last_name: "Deckard",
      email_name: "spec1",
      phone_number: "+1111111112",
      subscription_type: "PLATINUM",
      role: "member",
      type: "EXTERNAL",
      medical_categories: ["Dermatology", "Allergy & Immunology"]
    },
    %{
      first_name: "John",
      last_name: "Quimper",
      email_name: "spec2",
      phone_number: "+1111111113",
      subscription_type: "GOLD",
      role: "member",
      type: "EXTERNAL",
      medical_categories: ["Orthopedics & Physiotherapy", "Cosmetic Surgery"]
    },
    %{
      first_name: "Yuri",
      last_name: "Zhivago",
      email_name: "spec3",
      phone_number: "+1111111114",
      subscription_type: "SILVER",
      role: "member",
      type: "EXTERNAL",
      medical_categories: ["Mental Health", "OB/GYN"]
    },
    %{
      first_name: "Bernard",
      last_name: "Rieux",
      email_name: "spec4",
      phone_number: "+1111111115",
      subscription_type: "BASIC",
      role: "member",
      type: "EXTERNAL",
      medical_categories: [
        "Nutrition, Weight loss & Bariatrics",
        "Dentistry",
        "U.S Board Second Opinion"
      ]
    },
    %{
      first_name: "Jennifer",
      last_name: "Paige",
      email_name: "nurse1",
      phone_number: "+1111111116",
      subscription_type: "BASIC",
      role: "member",
      type: "NURSE",
      image_url:
        "https://storage.googleapis.com/dronline-prod/images/placeholders/default_woman_avatar.png"
    },
    %{
      first_name: "Clara",
      last_name: "Barton",
      email_name: "nurse2",
      phone_number: "+1111111117",
      subscription_type: "BASIC",
      role: "member",
      type: "NURSE",
      image_url:
        "https://storage.googleapis.com/dronline-prod/images/placeholders/default_woman_avatar.png"
    }
  ]

  def seed(shared_password, admin_password, email_prefix) do
    with {:ok, _admin} <-
           insert_admin(@admin,
             password: admin_password,
             email_prefix: email_prefix
           ),
         {:ok, team_owner} <-
           insert_specialist(@team_owner,
             password: shared_password,
             email_prefix: email_prefix
           ),
         {:ok, team} <- insert_team(team_owner_id: team_owner.id),
         {:ok, _team_credentials} <-
           insert_team_credentials(
             team_id: team.id,
             password: shared_password
           ),
         {:ok, _specialists} <-
           insert_specialists(
             team_id: team.id,
             password: shared_password,
             email_prefix: email_prefix
           ) do
      :ok
    else
      other ->
        _ = Logger.error(other)
        throw("Specialists seeding error")
    end
  end

  defp insert_specialists(
         team_id: team_id,
         password: password,
         email_prefix: email_prefix
       ) do
    specialists =
      [@team_owner | @team_members]
      |> Enum.map(fn params ->
        with {:ok, specialist} <-
               insert_specialist(
                 params,
                 password: password,
                 email_prefix: email_prefix
               ),
             {:ok, _basic_info} <-
               insert_basic_info(
                 params,
                 specialist_id: specialist.id
               ),
             {:ok, _specialist_medical_categories} <-
               insert_specialist_medical_categories(
                 params,
                 specialist_id: specialist.id
               ),
             {:ok, _subscription} <-
               insert_subscription(
                 params,
                 specialist_id: specialist.id
               ),
             {:ok, _specialist_team_member} <-
               insert_team_member(
                 params,
                 team_id: team_id,
                 specialist_id: specialist.id
               ),
             {:ok, _specialist_location} <-
               insert_specialist_location(specialist_id: specialist.id) do
          specialist
        else
          other ->
            _ = Logger.error(other)
            throw("Specialist seeding error")
        end
      end)

    {:ok, specialists}
  end

  defp insert_specialist(params,
         password: password,
         email_prefix: email_prefix
       ) do
    email = email_prefix <> params.email_name <> "@appunite.com"

    specialist_params = %{
      type: params.type,
      package_type: params.subscription_type,
      email: email,
      password_hash: Pbkdf2.hash_pwd_salt(password),
      auth_token: "FAKE_SPECIALIST_TOKEN_" <> params.email_name,
      verified: true,
      onboarding_completed_at: ~N[2020-10-10 10:10:10],
      approval_status: "VERIFIED",
      approval_status_updated_at: DateTime.utc_now()
    }

    Specialist
    |> where(email: ^email)
    |> Repo.one()
    |> Specialist.changeset(specialist_params)
    |> Repo.insert_or_update()
  end

  defp insert_admin(params, password: password, email_prefix: email_prefix) do
    email = email_prefix <> params.email_name <> "@appunite.com"

    admin_params = %{
      email: email,
      auth_token: "FAKE_ADMIN_TOKEN",
      password_hash: Pbkdf2.hash_pwd_salt(password)
    }

    Administrator
    |> where(email: ^email)
    |> Repo.one()
    |> Administrator.changeset(admin_params)
    |> Repo.insert_or_update()
  end

  defp insert_basic_info(params, specialist_id: specialist_id) do
    basic_info_params = %{
      specialist_id: specialist_id,
      title: "MR",
      first_name: params.first_name,
      last_name: params.last_name,
      birth_date: ~D[1980-10-10],
      phone_number: params.phone_number,
      gender: "MALE",
      medical_title: "M_D",
      image_url:
        params[:image_url] ||
          "https://storage.googleapis.com/dronline-prod/images/placeholders/default_boy_avatar.png"
    }

    BasicInfo
    |> where(specialist_id: ^specialist_id)
    |> Repo.one()
    |> BasicInfo.changeset(basic_info_params)
    |> Repo.insert_or_update()
  end

  defp insert_subscription(params, specialist_id: specialist_id) do
    subscription_params = %{
      specialist_id: specialist_id,
      type: params.subscription_type
    }

    Subscription
    |> where(specialist_id: ^specialist_id)
    |> Repo.one()
    |> Subscription.changeset(subscription_params)
    |> Repo.insert_or_update()
  end

  defp insert_team(team_owner_id: owner_id) do
    team_params = %{
      owner_id: owner_id,
      formatted_address: "Droga Dębińska 3A, 61-555 Poznań, Poland",
      location: %Geo.Point{coordinates: {52.39777789999999, 16.935533}, srid: 4326}
    }

    Team
    |> where(owner_id: ^owner_id)
    |> Repo.one()
    |> Team.changeset(team_params)
    |> Repo.insert_or_update()
  end

  defp insert_team_credentials(team_id: team_id, password: password) do
    identifier = "Developers Team"

    team_credentials_params = %{
      team_id: team_id,
      identifier: identifier,
      encrypted_password: Pbkdf2.hash_pwd_salt(password)
    }

    TeamCredentials
    |> where(identifier: ^identifier)
    |> Repo.one()
    |> TeamCredentials.changeset(team_credentials_params)
    |> Repo.insert_or_update()
  end

  defp insert_team_member(params, team_id: team_id, specialist_id: specialist_id) do
    team_member_params = %{
      specialist_id: specialist_id,
      team_id: team_id,
      role: params.role
    }

    TeamMember
    |> where(specialist_id: ^specialist_id)
    |> Repo.one()
    |> TeamMember.changeset(team_member_params)
    |> Repo.insert_or_update()
  end

  defp insert_specialist_medical_categories(
         %{type: "EXTERNAL", medical_categories: medical_categories} = _params,
         specialist_id: specialist_id
       ) do
    medical_categories
    |> Enum.each(fn category_name ->
      id =
        MedicalCategory
        |> where(name: ^category_name)
        |> limit(1)
        |> select([c], c.id)
        |> Repo.one()

      specialist_medical_category_params = %{
        specialist_id: specialist_id,
        medical_category_id: id
      }

      SpecialistsMedicalCategory
      |> where(specialist_id: ^specialist_id, medical_category_id: ^id)
      |> Repo.one()
      |> SpecialistsMedicalCategory.changeset(specialist_medical_category_params)
      |> Repo.insert_or_update()
    end)

    {:ok, nil}
  end

  defp insert_specialist_medical_categories(_params, _specialist), do: {:ok, nil}

  defp insert_specialist_location(specialist_id: specialist_id) do
    specialist_location_params = %{
      specialist_id: specialist_id,
      country: "Poland",
      formatted_address: "Droga Dębińska 3A, 61-555 Poznań, Poland",
      coordinates: %Geo.Point{coordinates: {52.39777789999999, 16.935533}, srid: 4326}
    }

    SpecialistLocation
    |> where(specialist_id: ^specialist_id)
    |> Repo.one()
    |> SpecialistLocation.changeset(specialist_location_params)
    |> Repo.insert_or_update()
  end
end

defmodule Postgres.Seeds.Specialist do
  use Postgres.Schema
  use Postgres.Service

  schema "specialists" do
    field :type, :string
    field :package_type, :string
    field :email, :string
    field :password_hash, :string
    field :auth_token, :string
    field :verified, :boolean
    field :onboarding_completed_at, :naive_datetime_usec
    field :approval_status, :string
    field :approval_status_updated_at, :naive_datetime_usec

    timestamps()
  end

  @fields [
    :type,
    :package_type,
    :email,
    :password_hash,
    :auth_token,
    :verified,
    :onboarding_completed_at,
    :approval_status,
    :approval_status_updated_at
  ]
  def changeset(nil, params), do: changeset(%__MODULE__{}, params)
  def changeset(struct, params), do: cast(struct, params, @fields)
end

defmodule Postgres.Seeds.BasicInfo do
  use Postgres.Schema
  use Postgres.Service

  schema "specialist_basic_infos" do
    field :title, :string
    field :first_name, :string
    field :last_name, :string
    field :birth_date, :date
    field :image_url, :string
    field :phone_number, :string
    field :gender, :string
    field :medical_title, :string, default: "MD"

    field :specialist_id, :integer

    timestamps()
  end

  @fields [
    :specialist_id,
    :title,
    :first_name,
    :last_name,
    :birth_date,
    :image_url,
    :phone_number,
    :gender,
    :medical_title
  ]
  def changeset(nil, params), do: changeset(%__MODULE__{}, params)
  def changeset(struct, params), do: cast(struct, params, @fields)
end

defmodule Postgres.Seeds.Subscription do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:specialist_id, :integer, autogenerate: false}
  schema "mocked_subscriptions" do
    field :type, :string

    timestamps()
  end

  @fields [
    :type,
    :specialist_id
  ]
  def changeset(nil, params), do: changeset(%__MODULE__{}, params)
  def changeset(struct, params), do: cast(struct, params, @fields)
end

defmodule Postgres.Seeds.Team do
  use Postgres.Schema

  schema "specialist_teams" do
    field :location, Geo.PostGIS.Geometry
    field :formatted_address, :string
    field :owner_id, :integer

    timestamps()
  end

  @fields [
    :location,
    :formatted_address,
    :owner_id
  ]
  def changeset(nil, params), do: changeset(%__MODULE__{}, params)
  def changeset(struct, params), do: cast(struct, params, @fields)
end

defmodule Postgres.Seeds.TeamMember do
  use Postgres.Schema

  schema "specialist_team_members" do
    field :team_id, :integer
    field :specialist_id, :integer
    field :role, :string

    timestamps()
  end

  @fields [
    :team_id,
    :specialist_id,
    :role
  ]
  def changeset(nil, params), do: changeset(%__MODULE__{}, params)
  def changeset(struct, params), do: cast(struct, params, @fields)
end

defmodule Postgres.Seeds.Administrator do
  use Postgres.Schema

  schema "administrators" do
    field :email, :string
    field :auth_token, :string
    field :password_hash, :string

    timestamps()
  end

  @fields [
    :email,
    :auth_token,
    :password_hash
  ]
  def changeset(nil, params), do: changeset(%__MODULE__{}, params)
  def changeset(struct, params), do: cast(struct, params, @fields)
end

defmodule Postgres.Seeds.SpecialistsMedicalCategory do
  use Postgres.Schema

  schema "specialists_medical_categories" do
    field :specialist_id, :integer
    field :medical_category_id, :integer
  end

  @fields [
    :specialist_id,
    :medical_category_id
  ]
  def changeset(nil, params), do: changeset(%__MODULE__{}, params)
  def changeset(struct, params), do: cast(struct, params, @fields)
end

defmodule Postgres.Seeds.TeamCredentials do
  use Postgres.Schema

  schema "team_credentials" do
    field(:identifier, :string)
    field(:encrypted_password, :string)
    field(:team_id, :integer)

    timestamps()
  end

  @fields [
    :identifier,
    :encrypted_password,
    :team_id
  ]
  def changeset(nil, params), do: changeset(%__MODULE__{}, params)
  def changeset(struct, params), do: cast(struct, params, @fields)
end

defmodule Postgres.Seeds.SpecialistLocation do
  use Postgres.Schema

  schema "specialist_locations" do
    field(:country, :string)
    field(:formatted_address, :string)
    field(:coordinates, Geo.PostGIS.Geometry)
    field(:specialist_id, :integer)

    timestamps()
  end

  @fields [
    :country,
    :coordinates,
    :formatted_address,
    :specialist_id
  ]
  def changeset(nil, params), do: changeset(%__MODULE__{}, params)
  def changeset(struct, params), do: cast(struct, params, @fields)
end
