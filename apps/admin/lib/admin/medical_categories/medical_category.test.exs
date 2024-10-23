defmodule Admin.MedicalCategories.MedicalCategoryTest do
  use Postgres.DataCase, async: true
  alias Admin.MedicalCategories.MedicalCategory
  alias Postgres.Repo

  describe "fetch_all/0" do
    setup do
      {:ok, category} =
        %MedicalCategory{}
        |> MedicalCategory.changeset(%{
          name: "Sample Category",
          disabled: false,
          position: 1
        })
        |> Repo.insert()

      [category: category]
    end

    test "fetches all medical categories" do
      {:ok, medical_categories} = MedicalCategory.fetch_all()
      assert length(medical_categories) > 0
    end
  end

  describe "changeset/2" do
    test "returns a valid changeset for correct data" do
      attrs = %{name: "Test Category", disabled: false, position: 1}
      changeset = MedicalCategory.changeset(%MedicalCategory{}, attrs)

      assert changeset.valid?
    end

    test "returns an invalid changeset for incorrect data" do
      attrs = %{name: nil, disabled: false, position: -1}
      changeset = MedicalCategory.changeset(%MedicalCategory{}, attrs)

      refute changeset.valid?

      assert %{name: ["can't be blank"], position: ["must be greater than or equal to 0"]} ==
               errors_on(changeset)
    end
  end

  describe "update/2" do
    setup do
      {:ok, category} =
        %MedicalCategory{}
        |> MedicalCategory.changeset(%{
          name: "Existing Category",
          disabled: false,
          position: 1
        })
        |> Repo.insert()

      [category: category]
    end

    test "successfully updates a medical category", context do
      new_attrs = %{name: "Updated Category", disabled: true, position: 2}
      {:ok, category} = MedicalCategory.update(context[:category].id, new_attrs)
      assert category.name == "Updated Category"
      assert category.disabled == true
      assert category.position == 2
    end

    test "returns an error when category not found" do
      assert {:error, :not_found} = MedicalCategory.update(-1, %{name: "Nonexistent"})
    end
  end
end
