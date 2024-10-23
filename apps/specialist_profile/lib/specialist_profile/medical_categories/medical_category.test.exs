defmodule SpecialistProfile.MedicalCategories.MedicalCategoryTest do
  use Postgres.DataCase, async: true

  alias SpecialistProfile.MedicalCategories.MedicalCategory

  describe "fetch_all/0" do
    test "returns all categories except disabled" do
      %{id: parent_id} = parent = SpecialistProfile.Factory.insert(:medical_category, position: 1)

      %{id: sub_id} =
        SpecialistProfile.Factory.insert(:medical_category,
          parent_category_id: parent.id,
          position: 3
        )

      %{id: disabled_id} =
        SpecialistProfile.Factory.insert(:medical_category, disabled: true, position: 2)

      assert {:ok, [%{id: ^parent_id}, %{id: ^disabled_id}, %{id: ^sub_id}]} =
               MedicalCategory.fetch_all()
    end
  end

  describe "fetch_for_doctor/1" do
    test "returns only categories assigned to doctor with disabled" do
      _ = SpecialistProfile.Factory.insert(:medical_category)

      %{id: assigned_category_id} =
        SpecialistProfile.Factory.insert(:medical_category, disabled: false)

      %{id: disabled_category_id} =
        SpecialistProfile.Factory.insert(:medical_category, disabled: true)

      doctor = Authentication.Factory.insert(:specialist, type: "EXTERNAL")

      SpecialistProfile.update_medical_categories(
        [assigned_category_id, disabled_category_id],
        doctor.id
      )

      assert {:ok, returned_categories} = MedicalCategory.fetch_for_doctor(doctor.id)

      [%MedicalCategory{id: ^assigned_category_id}, %MedicalCategory{id: ^disabled_category_id}] =
        Enum.sort_by(returned_categories, & &1.disabled)
    end
  end

  describe "get_medical_categories_for_specialists/1" do
    test "returns mapping of specialist_ids and their categories names" do
      assigned_category = SpecialistProfile.Factory.insert(:medical_category, name: "Category")

      doctor = Authentication.Factory.insert(:specialist, type: "EXTERNAL")
      SpecialistProfile.update_medical_categories([assigned_category.id], doctor.id)

      assert result = MedicalCategory.get_medical_categories_for_specialists([doctor.id])
      assert result[doctor.id] == [%{id: assigned_category.id, name: "Category"}]
    end
  end

  describe "get_specialist_ids_for_medical_category/1" do
    test "returns list of specialist ids for given medical category" do
      category1 = SpecialistProfile.Factory.insert(:medical_category, name: "Category1")
      category2 = SpecialistProfile.Factory.insert(:medical_category, name: "Category2")

      doctor1 = Authentication.Factory.insert(:specialist, type: "EXTERNAL")
      SpecialistProfile.update_medical_categories([category1.id], doctor1.id)

      doctor2 = Authentication.Factory.insert(:specialist, type: "EXTERNAL")
      SpecialistProfile.update_medical_categories([category2.id], doctor2.id)

      doctor3 = Authentication.Factory.insert(:specialist, type: "EXTERNAL")
      SpecialistProfile.update_medical_categories([category1.id, category2.id], doctor3.id)

      expected_ids = [doctor1.id, doctor3.id]
      assert MedicalCategory.get_specialist_ids_for_medical_category(category1.id) == expected_ids

      expected_ids = [doctor2.id, doctor3.id]
      assert MedicalCategory.get_specialist_ids_for_medical_category(category2.id) == expected_ids
    end
  end
end
