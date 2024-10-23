defmodule Proto.SpecialistProfile.Status.ApprovalStatus do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN_STATUS | :WAITING | :VERIFIED | :REJECTED

  field :UNKNOWN_STATUS, 0

  field :WAITING, 1

  field :VERIFIED, 2

  field :REJECTED, 3
end

defmodule Proto.SpecialistProfile.Status.PackageType do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN_PACKAGE | :BASIC | :SILVER | :GOLD | :PLATINUM

  field :UNKNOWN_PACKAGE, 0

  field :BASIC, 1

  field :SILVER, 2

  field :GOLD, 3

  field :PLATINUM, 4
end

defmodule Proto.SpecialistProfile.GetCredentialsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          credentials: Proto.SpecialistProfile.Credentials.t() | nil
        }

  defstruct [:credentials]

  field :credentials, 1, type: Proto.SpecialistProfile.Credentials
end

defmodule Proto.SpecialistProfile.GetBasicInfoResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          basic_info: Proto.SpecialistProfile.BasicInfo.t() | nil
        }

  defstruct [:basic_info]

  field :basic_info, 1, type: Proto.SpecialistProfile.BasicInfo
end

defmodule Proto.SpecialistProfile.UpdateBasicInfoRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          basic_info: Proto.SpecialistProfile.BasicInfo.t() | nil
        }

  defstruct [:basic_info]

  field :basic_info, 1, type: Proto.SpecialistProfile.BasicInfo
end

defmodule Proto.SpecialistProfile.UpdateBasicInfoResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          basic_info: Proto.SpecialistProfile.BasicInfo.t() | nil
        }

  defstruct [:basic_info]

  field :basic_info, 1, type: Proto.SpecialistProfile.BasicInfo
end

defmodule Proto.SpecialistProfile.GetBioResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          bio: Proto.SpecialistProfile.Bio.t() | nil
        }

  defstruct [:bio]

  field :bio, 1, type: Proto.SpecialistProfile.Bio
end

defmodule Proto.SpecialistProfile.UpdateBioRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          bio: Proto.SpecialistProfile.Bio.t() | nil
        }

  defstruct [:bio]

  field :bio, 1, type: Proto.SpecialistProfile.Bio
end

defmodule Proto.SpecialistProfile.UpdateBioResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          bio: Proto.SpecialistProfile.Bio.t() | nil
        }

  defstruct [:bio]

  field :bio, 1, type: Proto.SpecialistProfile.Bio
end

defmodule Proto.SpecialistProfile.GetLocationResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          location: Proto.SpecialistProfile.Location.t() | nil
        }

  defstruct [:location]

  field :location, 1, type: Proto.SpecialistProfile.Location
end

defmodule Proto.SpecialistProfile.GetPricesResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          categories_prices: [Proto.SpecialistProfile.CategoryPricesResponse.t()]
        }

  defstruct [:categories_prices]

  field :categories_prices, 1,
    repeated: true,
    type: Proto.SpecialistProfile.CategoryPricesResponse
end

defmodule Proto.SpecialistProfile.UpdatePricesRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          category_prices: Proto.SpecialistProfile.CategoryPricesRequest.t() | nil
        }

  defstruct [:category_prices]

  field :category_prices, 1, type: Proto.SpecialistProfile.CategoryPricesRequest
end

defmodule Proto.SpecialistProfile.UpdatePricesResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          category_prices: Proto.SpecialistProfile.CategoryPricesResponse.t() | nil
        }

  defstruct [:category_prices]

  field :category_prices, 1, type: Proto.SpecialistProfile.CategoryPricesResponse
end

defmodule Proto.SpecialistProfile.UpdateLocationRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          location: Proto.SpecialistProfile.Location.t() | nil
        }

  defstruct [:location]

  field :location, 1, type: Proto.SpecialistProfile.Location
end

defmodule Proto.SpecialistProfile.UpdateLocationResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          location: Proto.SpecialistProfile.Location.t() | nil
        }

  defstruct [:location]

  field :location, 1, type: Proto.SpecialistProfile.Location
end

defmodule Proto.SpecialistProfile.GetMedicalCredentialsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          medical_credentials: Proto.SpecialistProfile.MedicalCredentials.t() | nil
        }

  defstruct [:medical_credentials]

  field :medical_credentials, 1, type: Proto.SpecialistProfile.MedicalCredentials
end

defmodule Proto.SpecialistProfile.UpdateMedicalCredentialsRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          medical_credentials: Proto.SpecialistProfile.MedicalCredentials.t() | nil
        }

  defstruct [:medical_credentials]

  field :medical_credentials, 1, type: Proto.SpecialistProfile.MedicalCredentials
end

defmodule Proto.SpecialistProfile.UpdateMedicalCredentialsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          medical_credentials: Proto.SpecialistProfile.MedicalCredentials.t() | nil
        }

  defstruct [:medical_credentials]

  field :medical_credentials, 1, type: Proto.SpecialistProfile.MedicalCredentials
end

defmodule Proto.SpecialistProfile.GetMedicalCategoriesResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          medical_categories: [Proto.MedicalCategories.MedicalCategoryBase.t()]
        }

  defstruct [:medical_categories]

  field :medical_categories, 1, repeated: true, type: Proto.MedicalCategories.MedicalCategoryBase
end

defmodule Proto.SpecialistProfile.UpdateMedicalCategoriesRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          medical_categories: [Proto.MedicalCategories.MedicalCategoryBase.t()]
        }

  defstruct [:medical_categories]

  field :medical_categories, 1, repeated: true, type: Proto.MedicalCategories.MedicalCategoryBase
end

defmodule Proto.SpecialistProfile.UpdateMedicalCategoriesResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          medical_categories: [Proto.MedicalCategories.MedicalCategoryBase.t()]
        }

  defstruct [:medical_categories]

  field :medical_categories, 1, repeated: true, type: Proto.MedicalCategories.MedicalCategoryBase
end

defmodule Proto.SpecialistProfile.UpdateMedicalInfoRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          medical_info: Proto.SpecialistProfile.MedicalInfo.t() | nil
        }

  defstruct [:medical_info]

  field :medical_info, 1, type: Proto.SpecialistProfile.MedicalInfo
end

defmodule Proto.SpecialistProfile.UpdateMedicalInfoResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          medical_info: Proto.SpecialistProfile.MedicalInfo.t() | nil
        }

  defstruct [:medical_info]

  field :medical_info, 1, type: Proto.SpecialistProfile.MedicalInfo
end

defmodule Proto.SpecialistProfile.GetStatusResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          status: Proto.SpecialistProfile.Status.t() | nil
        }

  defstruct [:status]

  field :status, 1, type: Proto.SpecialistProfile.Status
end

defmodule Proto.SpecialistProfile.Credentials do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          email: String.t(),
          id: non_neg_integer
        }

  defstruct [:email, :id]

  field :email, 2, type: :string
  field :id, 3, type: :uint64
end

defmodule Proto.SpecialistProfile.GetSpecialistsInCategoryResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          specialists: [Proto.Generics.Specialist.t()]
        }

  defstruct [:specialists]

  field :specialists, 1, repeated: true, type: Proto.Generics.Specialist
end

defmodule Proto.SpecialistProfile.GetSpecialistsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          specialists: [Proto.SpecialistProfile.DetailedSpecialist.t()],
          next_token: String.t()
        }

  defstruct [:specialists, :next_token]

  field :specialists, 1, repeated: true, type: Proto.SpecialistProfile.DetailedSpecialist
  field :next_token, 2, type: :string
end

defmodule Proto.SpecialistProfile.DetailedSpecialist do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          specialist: Proto.Generics.Specialist.t() | nil,
          country: String.t()
        }

  defstruct [:specialist, :country]

  field :specialist, 1, type: Proto.Generics.Specialist
  field :country, 2, type: :string
end

defmodule Proto.SpecialistProfile.BasicInfo do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          title: Proto.Generics.Title.t(),
          first_name: String.t(),
          last_name: String.t(),
          birth_date: Proto.Generics.DateTime.t() | nil,
          image_url: String.t(),
          phone_number: String.t(),
          gender: Proto.Generics.Gender.t(),
          medical_title: Proto.Generics.MedicalTitle.t()
        }

  defstruct [
    :title,
    :first_name,
    :last_name,
    :birth_date,
    :image_url,
    :phone_number,
    :gender,
    :medical_title
  ]

  field :title, 1, type: Proto.Generics.Title, enum: true
  field :first_name, 2, type: :string
  field :last_name, 3, type: :string
  field :birth_date, 4, type: Proto.Generics.DateTime
  field :image_url, 5, type: :string
  field :phone_number, 6, type: :string
  field :gender, 7, type: Proto.Generics.Gender, enum: true
  field :medical_title, 8, type: Proto.Generics.MedicalTitle, enum: true
end

defmodule Proto.SpecialistProfile.Location do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          street: String.t(),
          number: String.t(),
          postal_code: String.t(),
          city: String.t(),
          country: String.t(),
          additional_numbers: String.t(),
          neighborhood: String.t(),
          formatted_address: String.t(),
          coordinates: Proto.Generics.Coordinates.t() | nil
        }

  defstruct [
    :street,
    :number,
    :postal_code,
    :city,
    :country,
    :additional_numbers,
    :neighborhood,
    :formatted_address,
    :coordinates
  ]

  field :street, 1, type: :string
  field :number, 2, type: :string
  field :postal_code, 4, type: :string
  field :city, 5, type: :string
  field :country, 6, type: :string
  field :additional_numbers, 7, type: :string
  field :neighborhood, 8, type: :string
  field :formatted_address, 9, type: :string
  field :coordinates, 10, type: Proto.Generics.Coordinates
end

defmodule Proto.SpecialistProfile.MedicalCredentials do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          dea_number_url: String.t(),
          dea_number_expiry_date: Proto.Generics.DateTime.t() | nil,
          board_certification_url: String.t(),
          board_certification_expiry_date: Proto.Generics.DateTime.t() | nil,
          current_state_license_number_url: String.t(),
          current_state_license_number_expiry_date: Proto.Generics.DateTime.t() | nil
        }

  defstruct [
    :dea_number_url,
    :dea_number_expiry_date,
    :board_certification_url,
    :board_certification_expiry_date,
    :current_state_license_number_url,
    :current_state_license_number_expiry_date
  ]

  field :dea_number_url, 1, type: :string
  field :dea_number_expiry_date, 2, type: Proto.Generics.DateTime
  field :board_certification_url, 3, type: :string
  field :board_certification_expiry_date, 4, type: Proto.Generics.DateTime
  field :current_state_license_number_url, 5, type: :string
  field :current_state_license_number_expiry_date, 6, type: Proto.Generics.DateTime
end

defmodule Proto.SpecialistProfile.MedicalCategories do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          categories: [Proto.MedicalCategories.MedicalCategoryBase.t()]
        }

  defstruct [:categories]

  field :categories, 1, repeated: true, type: Proto.MedicalCategories.MedicalCategoryBase
end

defmodule Proto.SpecialistProfile.Status do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          onboarding_completed: boolean,
          approval_status: Proto.SpecialistProfile.Status.ApprovalStatus.t(),
          package_type: Proto.SpecialistProfile.Status.PackageType.t(),
          trial_ends_at: non_neg_integer,
          has_seen_pricing_tables: boolean
        }

  defstruct [
    :onboarding_completed,
    :approval_status,
    :package_type,
    :trial_ends_at,
    :has_seen_pricing_tables
  ]

  field :onboarding_completed, 1, type: :bool
  field :approval_status, 2, type: Proto.SpecialistProfile.Status.ApprovalStatus, enum: true
  field :package_type, 3, type: Proto.SpecialistProfile.Status.PackageType, enum: true
  field :trial_ends_at, 4, type: :uint64
  field :has_seen_pricing_tables, 5, type: :bool
end

defmodule Proto.SpecialistProfile.MedicalInfo do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          medical_credentials: Proto.SpecialistProfile.MedicalCredentials.t() | nil,
          medical_categories: [Proto.MedicalCategories.MedicalCategoryBase.t()]
        }

  defstruct [:medical_credentials, :medical_categories]

  field :medical_credentials, 1, type: Proto.SpecialistProfile.MedicalCredentials
  field :medical_categories, 2, repeated: true, type: Proto.MedicalCategories.MedicalCategoryBase
end

defmodule Proto.SpecialistProfile.Bio do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          description: String.t(),
          education: [Proto.SpecialistProfile.EducationEntry.t()],
          work_experience: [Proto.SpecialistProfile.WorkExperienceEntry.t()]
        }

  defstruct [:description, :education, :work_experience]

  field :description, 1, type: :string
  field :education, 2, repeated: true, type: Proto.SpecialistProfile.EducationEntry
  field :work_experience, 3, repeated: true, type: Proto.SpecialistProfile.WorkExperienceEntry
end

defmodule Proto.SpecialistProfile.EducationEntry do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          school: String.t(),
          field_of_study: String.t(),
          degree: String.t(),
          start_year: non_neg_integer,
          end_year: non_neg_integer
        }

  defstruct [:school, :field_of_study, :degree, :start_year, :end_year]

  field :school, 1, type: :string
  field :field_of_study, 2, type: :string
  field :degree, 3, type: :string
  field :start_year, 4, type: :uint32
  field :end_year, 5, type: :uint32
end

defmodule Proto.SpecialistProfile.WorkExperienceEntry do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          institution: String.t(),
          position: String.t(),
          start_year: non_neg_integer,
          end_year: non_neg_integer
        }

  defstruct [:institution, :position, :start_year, :end_year]

  field :institution, 1, type: :string
  field :position, 2, type: :string
  field :start_year, 3, type: :uint32
  field :end_year, 4, type: :uint32
end

defmodule Proto.SpecialistProfile.CategoryPricesResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          medical_category_id: non_neg_integer,
          medical_category_name: String.t(),
          medical_category_image_url: String.t(),
          price_minutes_15: non_neg_integer,
          price_minutes_30: non_neg_integer,
          price_minutes_45: non_neg_integer,
          price_minutes_60: non_neg_integer,
          price_second_opinion: non_neg_integer,
          prices_enabled: boolean,
          currency: String.t(),
          price_in_office: non_neg_integer,
          currency_in_office: String.t()
        }

  defstruct [
    :medical_category_id,
    :medical_category_name,
    :medical_category_image_url,
    :price_minutes_15,
    :price_minutes_30,
    :price_minutes_45,
    :price_minutes_60,
    :price_second_opinion,
    :prices_enabled,
    :currency,
    :price_in_office,
    :currency_in_office
  ]

  field :medical_category_id, 1, type: :uint64
  field :medical_category_name, 2, type: :string
  field :medical_category_image_url, 3, type: :string
  field :price_minutes_15, 4, type: :uint64
  field :price_minutes_30, 5, type: :uint64
  field :price_minutes_45, 6, type: :uint64
  field :price_minutes_60, 7, type: :uint64
  field :price_second_opinion, 8, type: :uint64
  field :prices_enabled, 9, type: :bool
  field :currency, 10, type: :string
  field :price_in_office, 11, type: :uint64
  field :currency_in_office, 12, type: :string
end

defmodule Proto.SpecialistProfile.CategoryPricesRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          medical_category_id: non_neg_integer,
          price_minutes_15: non_neg_integer,
          price_minutes_30: non_neg_integer,
          price_minutes_45: non_neg_integer,
          price_minutes_60: non_neg_integer,
          price_second_opinion: non_neg_integer,
          currency: String.t(),
          price_in_office: non_neg_integer,
          currency_in_office: String.t()
        }

  defstruct [
    :medical_category_id,
    :price_minutes_15,
    :price_minutes_30,
    :price_minutes_45,
    :price_minutes_60,
    :price_second_opinion,
    :currency,
    :price_in_office,
    :currency_in_office
  ]

  field :medical_category_id, 1, type: :uint64
  field :price_minutes_15, 2, type: :uint64
  field :price_minutes_30, 3, type: :uint64
  field :price_minutes_45, 4, type: :uint64
  field :price_minutes_60, 5, type: :uint64
  field :price_second_opinion, 6, type: :uint64
  field :currency, 7, type: :string
  field :price_in_office, 8, type: :uint64
  field :currency_in_office, 9, type: :string
end
