defmodule Proto.SpecialistProfileV2.GetBasicInfoResponseV2 do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          basic_info: Proto.SpecialistProfileV2.BasicInfoV2.t() | nil
        }

  defstruct [:basic_info]

  field :basic_info, 1, type: Proto.SpecialistProfileV2.BasicInfoV2
end

defmodule Proto.SpecialistProfileV2.UpdateBasicInfoRequestV2 do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          basic_info: Proto.SpecialistProfileV2.BasicInfoV2.t() | nil
        }

  defstruct [:basic_info]

  field :basic_info, 1, type: Proto.SpecialistProfileV2.BasicInfoV2
end

defmodule Proto.SpecialistProfileV2.UpdateBasicInfoResponseV2 do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          basic_info: Proto.SpecialistProfileV2.BasicInfoV2.t() | nil
        }

  defstruct [:basic_info]

  field :basic_info, 1, type: Proto.SpecialistProfileV2.BasicInfoV2
end

defmodule Proto.SpecialistProfileV2.GetProfileDescriptionResponseV2 do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          profile_description: Proto.SpecialistProfileV2.ProfileDescriptionV2.t() | nil
        }

  defstruct [:profile_description]

  field :profile_description, 1, type: Proto.SpecialistProfileV2.ProfileDescriptionV2
end

defmodule Proto.SpecialistProfileV2.UpdateProfileDescriptionRequestV2 do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          profile_description: Proto.SpecialistProfileV2.ProfileDescriptionV2.t() | nil
        }

  defstruct [:profile_description]

  field :profile_description, 1, type: Proto.SpecialistProfileV2.ProfileDescriptionV2
end

defmodule Proto.SpecialistProfileV2.UpdateProfileDescriptionResponseV2 do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          profile_description: Proto.SpecialistProfileV2.ProfileDescriptionV2.t() | nil
        }

  defstruct [:profile_description]

  field :profile_description, 1, type: Proto.SpecialistProfileV2.ProfileDescriptionV2
end

defmodule Proto.SpecialistProfileV2.GetEducationResponseV2 do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          education: [Proto.SpecialistProfileV2.EducationEntryV2.t()]
        }

  defstruct [:education]

  field :education, 1, repeated: true, type: Proto.SpecialistProfileV2.EducationEntryV2
end

defmodule Proto.SpecialistProfileV2.UpdateEducationRequestV2 do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          education: [Proto.SpecialistProfileV2.EducationEntryV2.t()]
        }

  defstruct [:education]

  field :education, 1, repeated: true, type: Proto.SpecialistProfileV2.EducationEntryV2
end

defmodule Proto.SpecialistProfileV2.UpdateEducationResponseV2 do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          education: [Proto.SpecialistProfileV2.EducationEntryV2.t()]
        }

  defstruct [:education]

  field :education, 1, repeated: true, type: Proto.SpecialistProfileV2.EducationEntryV2
end

defmodule Proto.SpecialistProfileV2.GetWorkExperienceV2 do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          work_experience: [Proto.SpecialistProfileV2.WorkExperienceEntryV2.t()]
        }

  defstruct [:work_experience]

  field :work_experience, 1, repeated: true, type: Proto.SpecialistProfileV2.WorkExperienceEntryV2
end

defmodule Proto.SpecialistProfileV2.UpdateWorkExperienceRequestV2 do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          work_experience: [Proto.SpecialistProfileV2.WorkExperienceEntryV2.t()]
        }

  defstruct [:work_experience]

  field :work_experience, 1, repeated: true, type: Proto.SpecialistProfileV2.WorkExperienceEntryV2
end

defmodule Proto.SpecialistProfileV2.UpdateWorkExperienceResponseV2 do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          work_experience: [Proto.SpecialistProfileV2.WorkExperienceEntryV2.t()]
        }

  defstruct [:work_experience]

  field :work_experience, 1, repeated: true, type: Proto.SpecialistProfileV2.WorkExperienceEntryV2
end

defmodule Proto.SpecialistProfileV2.GetMedicalInfoResponseV2 do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          medical_info: Proto.SpecialistProfileV2.MedicalInfoV2.t() | nil
        }

  defstruct [:medical_info]

  field :medical_info, 1, type: Proto.SpecialistProfileV2.MedicalInfoV2
end

defmodule Proto.SpecialistProfileV2.UpdateMedicalInfoRequestV2 do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          medical_info: Proto.SpecialistProfileV2.MedicalInfoV2.t() | nil
        }

  defstruct [:medical_info]

  field :medical_info, 1, type: Proto.SpecialistProfileV2.MedicalInfoV2
end

defmodule Proto.SpecialistProfileV2.UpdateMedicalInfoResponseV2 do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          medical_info: Proto.SpecialistProfileV2.MedicalInfoV2.t() | nil
        }

  defstruct [:medical_info]

  field :medical_info, 1, type: Proto.SpecialistProfileV2.MedicalInfoV2
end

defmodule Proto.SpecialistProfileV2.GetInsuranceProvidersV2 do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          insurance_providers: [Proto.SpecialistProfileV2.InsuranceProvidersEntryV2.t()],
          matching_provider: Proto.SpecialistProfileV2.MatchingInsuranceProviderV2.t() | nil
        }

  defstruct [:insurance_providers, :matching_provider]

  field :insurance_providers, 1,
    repeated: true,
    type: Proto.SpecialistProfileV2.InsuranceProvidersEntryV2

  field :matching_provider, 2, type: Proto.SpecialistProfileV2.MatchingInsuranceProviderV2
end

defmodule Proto.SpecialistProfileV2.UpdateInsuranceProvidersRequestV2 do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          insurance_providers: [Proto.SpecialistProfileV2.InsuranceProvidersEntryV2.t()]
        }

  defstruct [:insurance_providers]

  field :insurance_providers, 1,
    repeated: true,
    type: Proto.SpecialistProfileV2.InsuranceProvidersEntryV2
end

defmodule Proto.SpecialistProfileV2.UpdateInsuranceProvidersResponseV2 do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          insurance_providers: [Proto.SpecialistProfileV2.InsuranceProvidersEntryV2.t()]
        }

  defstruct [:insurance_providers]

  field :insurance_providers, 1,
    repeated: true,
    type: Proto.SpecialistProfileV2.InsuranceProvidersEntryV2
end

defmodule Proto.SpecialistProfileV2.SpecialistsSearchResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          specialists: [Proto.SpecialistProfileV2.SearchSpecialist.t()],
          next_token: String.t()
        }

  defstruct [:specialists, :next_token]

  field :specialists, 1, repeated: true, type: Proto.SpecialistProfileV2.SearchSpecialist
  field :next_token, 2, type: :string
end

defmodule Proto.SpecialistProfileV2.GetDetailedSpecialistsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          detailed_specialists: [Proto.SpecialistProfileV2.DetailedSpecialist.t()]
        }

  defstruct [:detailed_specialists]

  field :detailed_specialists, 1,
    repeated: true,
    type: Proto.SpecialistProfileV2.DetailedSpecialist
end

defmodule Proto.SpecialistProfileV2.BasicInfoV2 do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          first_name: String.t(),
          last_name: String.t(),
          gender: Proto.Generics.Gender.t(),
          birth_date: Proto.Generics.DateTime.t() | nil,
          profile_image_url: String.t(),
          medical_title: Proto.Generics.MedicalTitle.t(),
          phone_number: String.t(),
          address: Proto.SpecialistProfileV2.AddressV2.t() | nil
        }

  defstruct [
    :first_name,
    :last_name,
    :gender,
    :birth_date,
    :profile_image_url,
    :medical_title,
    :phone_number,
    :address
  ]

  field :first_name, 1, type: :string
  field :last_name, 2, type: :string
  field :gender, 3, type: Proto.Generics.Gender, enum: true
  field :birth_date, 4, type: Proto.Generics.DateTime
  field :profile_image_url, 5, type: :string
  field :medical_title, 7, type: Proto.Generics.MedicalTitle, enum: true
  field :phone_number, 8, type: :string
  field :address, 9, type: Proto.SpecialistProfileV2.AddressV2
end

defmodule Proto.SpecialistProfileV2.AddressV2 do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          street: String.t(),
          number: String.t(),
          postal_code: String.t(),
          city: String.t(),
          country: String.t(),
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
    :neighborhood,
    :formatted_address,
    :coordinates
  ]

  field :street, 1, type: :string
  field :number, 2, type: :string
  field :postal_code, 3, type: :string
  field :city, 4, type: :string
  field :country, 5, type: :string
  field :neighborhood, 6, type: :string
  field :formatted_address, 7, type: :string
  field :coordinates, 8, type: Proto.Generics.Coordinates
end

defmodule Proto.SpecialistProfileV2.ProfileDescriptionV2 do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          description: String.t()
        }

  defstruct [:description]

  field :description, 1, type: :string
end

defmodule Proto.SpecialistProfileV2.EducationEntryV2 do
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

defmodule Proto.SpecialistProfileV2.WorkExperienceEntryV2 do
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

defmodule Proto.SpecialistProfileV2.MedicalInfoV2 do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          medical_credentials: Proto.SpecialistProfileV2.MedicalCredentialsV2.t() | nil,
          medical_categories: [Proto.MedicalCategories.MedicalCategoryBase.t()]
        }

  defstruct [:medical_credentials, :medical_categories]

  field :medical_credentials, 1, type: Proto.SpecialistProfileV2.MedicalCredentialsV2
  field :medical_categories, 2, repeated: true, type: Proto.MedicalCategories.MedicalCategoryBase
end

defmodule Proto.SpecialistProfileV2.MedicalCredentialsV2 do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          board_certification_url: String.t(),
          board_certification_expiry_date: Proto.Generics.DateTime.t() | nil,
          current_state_license_number_url: String.t(),
          current_state_license_number_expiry_date: Proto.Generics.DateTime.t() | nil
        }

  defstruct [
    :board_certification_url,
    :board_certification_expiry_date,
    :current_state_license_number_url,
    :current_state_license_number_expiry_date
  ]

  field :board_certification_url, 1, type: :string
  field :board_certification_expiry_date, 2, type: Proto.Generics.DateTime
  field :current_state_license_number_url, 3, type: :string
  field :current_state_license_number_expiry_date, 4, type: Proto.Generics.DateTime
end

defmodule Proto.SpecialistProfileV2.InsuranceProvidersEntryV2 do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          name: String.t(),
          country_id: String.t()
        }

  defstruct [:id, :name, :country_id]

  field :id, 1, type: :uint64
  field :name, 2, type: :string
  field :country_id, 3, type: :string
end

defmodule Proto.SpecialistProfileV2.MatchingInsuranceProviderV2 do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          name: String.t()
        }

  defstruct [:id, :name]

  field :id, 1, type: :uint64
  field :name, 2, type: :string
end

defmodule Proto.SpecialistProfileV2.SearchSpecialist do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          first_name: String.t(),
          last_name: String.t(),
          avatar_url: String.t(),
          type: Proto.Generics.Specialist.Type.t(),
          package: Proto.Generics.Specialist.Package.t(),
          medical_categories: [Proto.Generics.Specialist.MedicalCategory.t()],
          medical_title: Proto.Generics.MedicalTitle.t(),
          location: Proto.SpecialistProfileV2.AddressV2.t() | nil,
          categories_prices: [Proto.SpecialistProfile.CategoryPricesResponse.t()],
          day_schedules: [Proto.Visits.DaySchedule.t()],
          insurance_providers: [Proto.SpecialistProfileV2.InsuranceProvidersEntryV2.t()]
        }

  defstruct [
    :id,
    :first_name,
    :last_name,
    :avatar_url,
    :type,
    :package,
    :medical_categories,
    :medical_title,
    :location,
    :categories_prices,
    :day_schedules,
    :insurance_providers
  ]

  field :id, 1, type: :uint64
  field :first_name, 2, type: :string
  field :last_name, 3, type: :string
  field :avatar_url, 4, type: :string
  field :type, 5, type: Proto.Generics.Specialist.Type, enum: true
  field :package, 6, type: Proto.Generics.Specialist.Package, enum: true
  field :medical_categories, 7, repeated: true, type: Proto.Generics.Specialist.MedicalCategory
  field :medical_title, 8, type: Proto.Generics.MedicalTitle, enum: true
  field :location, 9, type: Proto.SpecialistProfileV2.AddressV2

  field :categories_prices, 10,
    repeated: true,
    type: Proto.SpecialistProfile.CategoryPricesResponse

  field :day_schedules, 11, repeated: true, type: Proto.Visits.DaySchedule

  field :insurance_providers, 12,
    repeated: true,
    type: Proto.SpecialistProfileV2.InsuranceProvidersEntryV2
end

defmodule Proto.SpecialistProfileV2.DetailedSpecialist do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          specialist_generic_data: Proto.Generics.Specialist.t() | nil,
          prices: [Proto.SpecialistProfile.CategoryPricesResponse.t()],
          timeslots: [Proto.Visits.Timeslot.t()],
          insurance_providers: [Proto.SpecialistProfileV2.InsuranceProvidersEntryV2.t()],
          matching_provider: Proto.SpecialistProfileV2.MatchingInsuranceProviderV2.t() | nil
        }

  defstruct [
    :specialist_generic_data,
    :prices,
    :timeslots,
    :insurance_providers,
    :matching_provider
  ]

  field :specialist_generic_data, 1, type: Proto.Generics.Specialist
  field :prices, 2, repeated: true, type: Proto.SpecialistProfile.CategoryPricesResponse
  field :timeslots, 3, repeated: true, type: Proto.Visits.Timeslot

  field :insurance_providers, 4,
    repeated: true,
    type: Proto.SpecialistProfileV2.InsuranceProvidersEntryV2

  field :matching_provider, 5, type: Proto.SpecialistProfileV2.MatchingInsuranceProviderV2
end
