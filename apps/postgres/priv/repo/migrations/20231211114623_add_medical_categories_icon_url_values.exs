defmodule Postgres.Repo.Migrations.AddMedicalCategoriesIconUrlValues do
  use Ecto.Migration

  import Ecto.Query

  def change do
    query =
      from mc in "medical_categories",
        where:
          mc.name in [
            "Primary Care",
            "Surgical",
            "Dermatology",
            "Gastroenterology",
            "Medical",
            "Cardiology",
            "Endocrinology & Diabetes",
            "Genetics",
            "Mental Health",
            "Emergency Medicine",
            "Geriatrics",
            "Hepatology",
            "Nutrition & Weight loss",
            "Family Medicine",
            "Nephrology & Dialysis",
            "Neurology",
            "Allergy & Immunology",
            "Internal Medicine",
            "Oncology",
            "Pain Management",
            "Dentistry",
            "Internal Medicine - Pediatrics",
            "Physical Medicine & Rehabilitation",
            "Pulmonary & Intensive Care",
            "Oncology & Hematology",
            "OB-GYNs",
            "Radiation Oncology",
            "Radiology",
            "Rheumatology"
          ],
        update: [
          set: [
            icon_url:
              fragment(
                "CONCAT('https://storage.googleapis.com/dronline-prod/images/medical_categories_icons-v2/', REPLACE(?, ' ', '-'), '.png')",
                mc.name
              )
          ]
        ]

    Postgres.Repo.update_all(query, [])
  end
end
