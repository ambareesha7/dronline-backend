defmodule Postgres.Seeds.MedicalCategory do
  use Postgres.Schema
  use Postgres.Service

  alias __MODULE__

  schema "medical_categories" do
    field :name, :string
    field :image_url, :string
    field :what_we_treat_url, :string
    field :position, :integer
    field :disabled, :boolean
    field :parent_category_id, :integer

    timestamps()
  end

  @fields [
    :name,
    :image_url,
    :what_we_treat_url,
    :position,
    :disabled,
    :parent_category_id
  ]
  def changeset(nil, params), do: changeset(%__MODULE__{}, params)
  def changeset(struct, params), do: cast(struct, params, @fields)
end

defmodule Postgres.Seeds.MedicalCategories do
  import Ecto.Query

  alias Postgres.Repo
  alias Postgres.Seeds.MedicalCategory

  def seed do
    base_url = "https://storage.googleapis.com/dronline-prod/images/medical_categories-v2"
    guide_base_url = "#{Application.get_env(:web, :specialist_panel_url)}/webview/guide"

    list = [
      %{
        name: "Medical",
        position: 1,
        image_url: "#{base_url}/Medical.jpg",
        sub: [
          %{
            name: "Gastroenterology",
            image_url: "#{base_url}/Gastroenterology.jpg",
            what_we_treat_url: "#{guide_base_url}/what-is-triage-unit?category=gastroentology"
          },
          %{
            name: "Nephrology",
            image_url: "#{base_url}/Nephrology.jpg",
            what_we_treat_url: "#{guide_base_url}/what-is-triage-unit?category=nephrology"
          },
          %{
            name: "Neurology",
            image_url: "#{base_url}/Neurology.jpg",
            what_we_treat_url: "#{guide_base_url}/what-is-triage-unit?category=neurology"
          },
          %{
            name: "Pulmonology",
            image_url: "#{base_url}/Pulmonology.jpg",
            what_we_treat_url: "#{guide_base_url}/what-is-triage-unit?category=pulmonology",
            disabled: true
          },
          %{
            name: "Allergy & Immunology",
            image_url: "#{base_url}/Allergy-Immunology.jpg"
          },
          %{
            name: "Oncology",
            image_url: "#{base_url}/Oncology.jpg"
          },
          %{
            name: "General Medicine",
            image_url: "#{base_url}/General-Medicine.jpg",
            disabled: true
          },
          %{
            name: "Endocrinology & Diabetes",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Emergency Medicine",
            image_url: "#{base_url}/Placeholder.jpg",
            disabled: true
          },
          %{
            name: "Infectious Disease",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Nephrology & Dialysis",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Oncology & Hematology",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Pulmonary & Intensive Care",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Rheumatology",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Radiology",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Radiation Oncology",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Pain Management",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Geriatrics",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Cardiology",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Genetics",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Hepatology",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Physical Medicine & Rehabilitation",
            image_url: "#{base_url}/Placeholder.jpg"
          }
        ]
      },
      %{
        name: "Primary Care",
        position: 2,
        image_url: "#{base_url}/Pregnancy-Newborn-Pediatrics.jpg",
        sub: [
          %{
            name: "Family Medicine",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Internal Medicine - Pediatrics",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Pediatrician",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Internal Medicine",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "OB-GYNs",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Emergency Medicine",
            image_url: "#{base_url}/Placeholder.jpg"
          }
        ]
      },
      %{
        name: "Mental Health",
        position: 3,
        image_url: "#{base_url}/Mental-Health.jpg",
        sub: []
      },
      %{
        name: "U.S Board Second Opinion",
        position: 4,
        image_url: "#{base_url}/US-Board-Certified-Second-Opinion.jpg",
        sub: [
          %{
            name: "Allergy & Immunology",
            image_url: "#{base_url}/Allergy-Immunology.jpg"
          },
          %{
            name: "Bariatric Surgery",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Breast",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Cardiology",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Colorectal Surgery",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Cosmetic Surgery",
            image_url: "#{base_url}/Cosmetic-Surgery.jpg"
          },
          %{
            name: "Dermatology",
            image_url: "#{base_url}/Dermatology.jpg",
            what_we_treat_url: "#{guide_base_url}/what-is-triage-unit?category=dermatology"
          },
          %{
            name: "Endocrinology (medical)",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Endocrine Surgery",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "E.N.T.",
            image_url: "#{base_url}/ENT.jpg",
            what_we_treat_url: "#{guide_base_url}/what-is-triage-unit?category=e-n-t"
          },
          %{
            name: "E.N.T. Surgical Oncology",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Emergency Medicine",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Gastroenterology",
            image_url: "#{base_url}/Gastroenterology.jpg",
            what_we_treat_url: "#{guide_base_url}/what-is-triage-unit?category=gastroentology"
          },
          %{
            name: "General Surgery",
            image_url: "#{base_url}/General-Surgery.jpg"
          },
          %{
            name: "GYN Oncology",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "HIPEC",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Infectious Disease",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Internal Medicine",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Mental Health",
            image_url: "#{base_url}/Mental-Health.jpg"
          },
          %{
            name: "Nephrology & Dialysis",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Neurology",
            image_url: "#{base_url}/Neurology.jpg",
            what_we_treat_url: "#{guide_base_url}/what-is-triage-unit?category=neurology"
          },
          %{
            name: "Neuro Surgery",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "OB/GYN",
            image_url: "#{base_url}/OB-GYN.jpg",
            what_we_treat_url: "#{guide_base_url}/what-is-triage-unit?category=ob-gyn"
          },
          %{
            name: "Oncology (medical)",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Orthopedics & Physiotherapy",
            image_url: "#{base_url}/Orthopedics-Physiotherapy.jpg",
            what_we_treat_url: "#{guide_base_url}/what-is-triage-unit?category=orthopedics"
          },
          %{
            name: "Pediatrics & Newborn",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Pulmonology / Intensive Care",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Urology & Andrology",
            image_url: "#{base_url}/Urology-Andrology.jpg",
            what_we_treat_url: "#{guide_base_url}/what-is-triage-unit?category=urology"
          },
          %{
            name: "Vascular Surgery",
            image_url: "#{base_url}/Placeholder.jpg"
          }
        ]
      },
      %{
        name: "Pregnacy, Newborn & Pediatrics",
        position: 5,
        image_url: "#{base_url}/Pregnancy-Newborn-Pediatrics.jpg",
        disabled: true,
        sub: [
          %{
            name: "OB/GYN",
            image_url: "#{base_url}/OB-GYN.jpg",
            what_we_treat_url: "#{guide_base_url}/what-is-triage-unit?category=ob-gyn"
          },
          %{
            name: "Pediatrics",
            image_url: "#{base_url}/Pediatrics.jpg",
            what_we_treat_url: "#{guide_base_url}/what-is-triage-unit?category=pediatrics"
          }
        ]
      },
      %{
        name: "Nutrition, Weight loss & Bariatrics",
        position: 6,
        image_url: "#{base_url}/Nutrition-WeghtLoss-Bariatrics.jpg",
        disabled: true,
        sub: []
      },
      %{
        name: "Nutrition & Weight loss",
        position: 7,
        image_url: "#{base_url}/Nutrition-WeghtLoss-Bariatrics.jpg",
        sub: []
      },
      %{
        name: "Surgical",
        position: 8,
        image_url: "#{base_url}/Surgical.jpg",
        sub: [
          %{
            name: "E.N.T",
            image_url: "#{base_url}/ENT.jpg",
            what_we_treat_url: "#{guide_base_url}/what-is-triage-unit?category=e-n-t"
          },
          %{
            name: "Orthopedics & Physiotherapy",
            image_url: "#{base_url}/Orthopedics-Physiotherapy.jpg",
            what_we_treat_url: "#{guide_base_url}/what-is-triage-unit?category=orthopedics"
          },
          %{
            name: "Urology & Andrology",
            image_url: "#{base_url}/Urology-Andrology.jpg",
            what_we_treat_url: "#{guide_base_url}/what-is-triage-unit?category=urology"
          },
          %{
            name: "General surgery",
            image_url: "#{base_url}/General-Surgery.jpg"
          },
          %{
            name: "Vascular",
            image_url: "#{base_url}/Vascular.jpg"
          },
          %{
            name: "Cosmetic Surgery",
            image_url: "#{base_url}/Cosmetic-Surgery.jpg"
          },
          %{
            name: "Breast Surgery",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Colo-rectal Surgery",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "ENT Surgical Oncology",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "HIPEC Surgery",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Neuro Surgery",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Podiatry",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Bariatric",
            image_url: "#{base_url}/Placeholder.jpg"
          }
        ]
      },
      %{
        name: "Dermatology",
        position: 9,
        image_url: "#{base_url}/Dermatology.jpg",
        what_we_treat_url: "#{guide_base_url}/what-is-triage-unit?category=dermatology",
        sub: []
      },
      %{
        name: "Dentistry",
        position: 10,
        image_url: "#{base_url}/Dentistry.jpg",
        sub: [
          %{
            name: "General dentistry",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Pediatric dentistry",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Endodontist",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Orthodontist",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Periodontist",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Prosthodontist",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Oral & Maxillofascial",
            image_url: "#{base_url}/Placeholder.jpg"
          }
        ]
      },
      %{
        name: "Coronavirus Consultation",
        position: 11,
        image_url: "#{base_url}/Coronavirus.jpg",
        sub: [],
        disabled: true
      },
      %{
        name: "Pathology",
        position: 12,
        image_url: "#{base_url}/Placeholder.jpg",
        sub: [
          %{
            name: "Breast Pathology",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Gastrointestinal Pathology",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Genitourinary Pathology",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Gynecological Pathology",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Head & Neck Pathology",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Hematopathology",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Molecular Pathology",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Neuropathology",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Pediatric Pathology",
            image_url: "#{base_url}/Placeholder.jpg"
          }
        ]
      },
      %{
        name: "Radiology",
        position: 13,
        image_url: "#{base_url}/Placeholder.jpg",
        sub: [
          %{
            name: "Body imaging",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Breast imaging",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Cardiac imaging",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Interventional radiology",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "MRI imaging",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Neuro-radiology",
            image_url: "#{base_url}/Placeholder.jpg"
          },
          %{
            name: "Nuclear radiology",
            image_url: "#{base_url}/Placeholder.jpg"
          }
        ]
      }
    ]

    # Prevent unique constraint errors
    MedicalCategory
    |> Repo.update_all(set: [position: nil])

    list
    |> Enum.each(fn category_params ->
      {:ok, category} =
        MedicalCategory
        |> where(
          [c],
          c.name == ^category_params.name and is_nil(c.parent_category_id)
        )
        |> Repo.one()
        |> MedicalCategory.changeset(category_params)
        |> Repo.insert_or_update()

      Enum.each(category_params.sub, fn subcategory_params ->
        params = Map.merge(subcategory_params, %{parent_category_id: category.id})

        MedicalCategory
        |> where(
          name: ^subcategory_params.name,
          parent_category_id: ^category.id
        )
        |> Repo.one()
        |> MedicalCategory.changeset(params)
        |> Repo.insert_or_update()
      end)
    end)
  end
end
