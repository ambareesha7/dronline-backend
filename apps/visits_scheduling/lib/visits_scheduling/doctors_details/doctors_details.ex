defmodule VisitsScheduling.DoctorsDetails do
  defmodule Specialist do
    use Postgres.Schema

    schema "specialists" do
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

  defmodule SpecialistBasicInfo do
    use Postgres.Schema

    schema "specialist_basic_infos" do
      field :first_name, :string
      field :last_name, :string
      field :image_url, :string

      belongs_to :specialist, VisitsScheduling.FeaturedDoctors.Specialist

      many_to_many :medical_categories, VisitsScheduling.FeaturedDoctors.MedicalCategory,
        join_through: "specialists_medical_categories",
        join_keys: [specialist_id: :specialist_id, medical_category_id: :id]
    end
  end

  use Postgres.Service

  @typep doctor_details :: %{
           avatar_url: String.t(),
           categories: [],
           first_name: String.t(),
           id: pos_integer,
           last_name: String.t()
         }

  @doc """
  Fetches doctors details for given doctors ids
  """
  @spec fetch([pos_integer]) :: {:ok, [doctor_details]}
  def fetch(ids) do
    {:ok, result} =
      SpecialistBasicInfo
      |> join(:inner, [bi], s in assoc(bi, :specialist))
      |> join(:left, [bi], mc in assoc(bi, :medical_categories))
      |> preload([_bi, s, mc], medical_categories: mc, specialist: s)
      |> where([bi], bi.specialist_id in ^ids)
      |> where([bi, s], s.type in ["EXTERNAL"])
      |> Repo.fetch_all()

    {:ok, Enum.map(result, &parse_result/1)}
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
end
