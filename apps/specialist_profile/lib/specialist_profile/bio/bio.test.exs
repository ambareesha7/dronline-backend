defmodule SpecialistProfile.BioTest do
  use Postgres.DataCase, async: true

  alias SpecialistProfile.Bio

  describe "update/2" do
    test "creates new bio when it doesn't exist" do
      specialist_id = 1

      params = %{description: "Test Bio"}
      {:ok, bio} = Bio.update(specialist_id, params)

      assert bio.description == "Test Bio"
    end

    test "updates bio when it exists" do
      specialist_id = 1

      _basic_info =
        SpecialistProfile.Factory.insert(:bio, specialist_id: specialist_id, bio: "Test Bio 1")

      params = %{description: "Test Bio 2"}
      {:ok, bio} = Bio.update(specialist_id, params)

      assert bio.description == "Test Bio 2"
    end

    test "returns changeset when params are invalid" do
      specialist_id = 1

      params = %{bio: ""}

      assert {:error, %Ecto.Changeset{}} = Bio.update(specialist_id, params)
    end

    test "casts education embeds" do
      specialist_id = 1

      params = %{
        description: "Test",
        education: [
          %{
            school: "University 1",
            field_of_study: "Surgery",
            degree: "PhD",
            start_year: 2010,
            end_year: 2016
          },
          %{
            school: "University 2",
            field_of_study: "Surgery",
            degree: "PhD",
            start_year: 2016,
            end_year: 0
          }
        ]
      }

      {:ok, bio} = Bio.update(specialist_id, params)
      assert Enum.any?(bio.education, &match?(%{school: "University 1", end_year: 2016}, &1))
      assert Enum.any?(bio.education, &match?(%{school: "University 2", end_year: nil}, &1))
    end

    test "casts work experience embeds" do
      specialist_id = 1

      params = %{
        description: "Test",
        work_experience: [
          %{
            institution: "Hospital 1",
            position: "Surgeon",
            start_year: 2010,
            end_year: 2016
          },
          %{
            institution: "Hospital 2",
            position: "Surgeon",
            start_year: 2016,
            end_year: 0
          }
        ]
      }

      {:ok, bio} = Bio.update(specialist_id, params)
      work_experience = bio.work_experience
      assert Enum.any?(work_experience, &match?(%{institution: "Hospital 1", end_year: 2016}, &1))
      assert Enum.any?(work_experience, &match?(%{institution: "Hospital 2", end_year: nil}, &1))
    end
  end
end
