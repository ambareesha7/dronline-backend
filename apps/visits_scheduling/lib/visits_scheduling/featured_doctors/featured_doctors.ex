defmodule VisitsScheduling.FeaturedDoctors do
  defmodule Specialist do
    use Postgres.Schema

    schema "specialists" do
      field :approval_status, :string
      field :package_type, :string
      field :type, :string
    end
  end

  defmodule MedicalCategory do
    use Postgres.Schema

    schema "medical_categories" do
      field :name, :string
    end
  end

  # defmodule Subscription do
  #   use Postgres.Schema
  #
  #   schema "subscriptions" do
  #     field :active, :boolean
  #     field :last_payment_at, :naive_datetime_usec
  #     field :specialist_id, :integer
  #   end
  # end

  # workaround for mocked subscriptions
  defmodule Subscription do
    use Postgres.Schema

    @primary_key {:specialist_id, :integer, autogenerate: false}
    schema "mocked_subscriptions" do
      field :active, :boolean, virtual: true, default: true
      field :last_payment_at, :naive_datetime_usec, source: :updated_at
    end
  end

  defmodule SpecialistBasicInfo do
    use Postgres.Schema

    schema "specialist_basic_infos" do
      field :first_name, :string
      field :last_name, :string
      field :image_url, :string

      belongs_to :specialist, VisitsScheduling.FeaturedDoctors.Specialist

      has_many :subscriptions, VisitsScheduling.FeaturedDoctors.Subscription,
        foreign_key: :specialist_id,
        references: :specialist_id

      many_to_many :medical_categories, VisitsScheduling.FeaturedDoctors.MedicalCategory,
        join_through: "specialists_medical_categories",
        join_keys: [specialist_id: :specialist_id, medical_category_id: :id]
    end
  end

  use Postgres.Service

  defmacrop package_type_weight(column) do
    quote do
      fragment(
        "CASE
          WHEN ? = 'PLATINUM' THEN 1
          WHEN ? = 'GOLD' THEN 2
          WHEN ? = 'SILVER' THEN 3
          ELSE 4
        END",
        unquote(column),
        unquote(column),
        unquote(column)
      )
    end
  end

  defmacrop distance_between(column, geo_point) do
    quote do
      fragment(
        "ST_Distance(?, ?)",
        unquote(geo_point),
        unquote(column)
      )
    end
  end

  @typep featured_doctor :: %{
           avatar_url: String.t(),
           categories: [],
           first_name: String.t(),
           id: pos_integer,
           last_name: String.t()
         }

  @doc """
  Fetches at most 20 featured specialists
  """
  @spec fetch(map) :: {:ok, [featured_doctor]}
  def fetch(params \\ %{}) do
    {:ok, result} =
      params
      |> featured_doctors()
      |> where_minimum_active_package("SILVER")
      |> do_order_by(params)
      |> limit(20)
      |> Repo.fetch_all()

    {:ok, Enum.map(result, &parse_result/1)}
  end

  @doc """
  Fetches at most 20 featured specialists for given category_id
  """
  @spec fetch_for_category(map) :: {:ok, [featured_doctor]}
  def fetch_for_category(%{"medical_category_id" => category_id} = params) do
    {:ok, featured_result} =
      params
      |> featured_doctors()
      |> where([medical_category: mc], mc.id == ^category_id)
      |> do_order_by(params)
      |> limit(20)
      |> Repo.fetch_all()

    {:ok, Enum.map(featured_result, &parse_result/1)}
  end

  defp featured_doctors(params) do
    SpecialistBasicInfo
    |> join(:inner, [bi], s in assoc(bi, :specialist), as: :specialist)
    |> join(:left, [bi], mc in assoc(bi, :medical_categories), as: :medical_category)
    |> join_location(params)
    |> where([specialist: s], s.type == "EXTERNAL" and s.approval_status == "VERIFIED")
    |> filter_by_location(params)
    |> preload([specialist: s, medical_category: mc], medical_categories: mc, specialist: s)
  end

  defp where_minimum_active_package(query, "SILVER") do
    query
    # TODO uncomment when we will switch back to real subscriptions
    # |> where([subscription: sub], sub.active)
    |> where([specialist: s], s.package_type in ["SILVER", "GOLD", "PLATINUM"])
  end

  defp parse_result(%SpecialistBasicInfo{} = basic_info) do
    %{
      avatar_url: basic_info.image_url,
      categories: Enum.map(basic_info.medical_categories, &Map.get(&1, :name)),
      first_name: basic_info.first_name,
      id: basic_info.specialist_id,
      last_name: basic_info.last_name,
      package_type: basic_info.specialist.package_type |> String.to_existing_atom()
    }
  end

  defp join_location(query, %{"lat" => _, "lon" => _}) do
    query
    |> join(
      :inner_lateral,
      [specialist: s],
      sl in fragment(
        "SELECT * FROM specialist_locations AS sl
        WHERE sl.specialist_id = ?
        ORDER BY sl.specialist_id
        LIMIT 1",
        s.id
      ),
      as: :specialist_location,
      on: true
    )
  end

  defp join_location(query, _), do: query

  defp filter_by_location(query, %{"lat" => lat, "lon" => lon}) do
    one_hundred_miles_in_meters = 160_934

    query
    |> where(
      [specialist_location: sl],
      fragment(
        "ST_DWithin(?, ST_MakePoint(?, ?)::geography, ?)",
        sl.coordinates,
        ^lat,
        ^lon,
        ^one_hundred_miles_in_meters
      )
    )
  end

  defp filter_by_location(query, _), do: query

  defp do_order_by(query, %{"lat" => lat, "lon" => lon}) do
    query
    |> order_by(
      [
        specialist: s,
        specialist_location: sl
      ],
      asc: package_type_weight(s.package_type),
      asc:
        distance_between(
          sl.coordinates,
          ^%Geo.Point{
            coordinates: {lat, lon},
            srid: 4326
          }
        )
    )
  end

  defp do_order_by(query, _) do
    query
    |> order_by(
      [specialist: s],
      asc: package_type_weight(s.package_type)
    )
  end
end
