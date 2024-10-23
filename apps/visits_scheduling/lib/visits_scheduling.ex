defmodule VisitsScheduling do
  defdelegate fetch_doctors_details(doctors_ids),
    to: VisitsScheduling.DoctorsDetails,
    as: :fetch

  defdelegate fetch_featured_doctors(params),
    to: VisitsScheduling.FeaturedDoctors,
    as: :fetch

  defdelegate fetch_featured_doctors_for_category(params),
    to: VisitsScheduling.FeaturedDoctors,
    as: :fetch_for_category

  defdelegate fetch_medical_categories_root,
    to: VisitsScheduling.MedicalCategories.MedicalCategory,
    as: :fetch_root

  defdelegate fetch_medical_category(id),
    to: VisitsScheduling.MedicalCategories.MedicalCategory,
    as: :fetch_by_id

  defdelegate fetch_medical_subcategories(parent_id),
    to: VisitsScheduling.MedicalCategories.MedicalCategory,
    as: :fetch_subcategories
end
