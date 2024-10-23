defmodule Proto.PatientProfile.GetCredentialsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          credentials: Proto.PatientProfile.Credentials.t() | nil
        }

  defstruct [:credentials]

  field :credentials, 1, type: Proto.PatientProfile.Credentials
end

defmodule Proto.PatientProfile.GetBasicInfoResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          basic_info: Proto.PatientProfile.BasicInfo.t() | nil
        }

  defstruct [:basic_info]

  field :basic_info, 1, type: Proto.PatientProfile.BasicInfo
end

defmodule Proto.PatientProfile.UpdateBasicInfoRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          basic_info_params: Proto.PatientProfile.BasicInfoParams.t() | nil
        }

  defstruct [:basic_info_params]

  field :basic_info_params, 1, type: Proto.PatientProfile.BasicInfoParams
end

defmodule Proto.PatientProfile.UpdateBasicInfoResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          basic_info: Proto.PatientProfile.BasicInfo.t() | nil
        }

  defstruct [:basic_info]

  field :basic_info, 1, type: Proto.PatientProfile.BasicInfo
end

defmodule Proto.PatientProfile.GetBMIResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          bmi: Proto.PatientProfile.BMI.t() | nil
        }

  defstruct [:bmi]

  field :bmi, 1, type: Proto.PatientProfile.BMI
end

defmodule Proto.PatientProfile.UpdateBMIRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          bmi: Proto.PatientProfile.BMI.t() | nil
        }

  defstruct [:bmi]

  field :bmi, 1, type: Proto.PatientProfile.BMI
end

defmodule Proto.PatientProfile.UpdateBMIResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          bmi: Proto.PatientProfile.BMI.t() | nil
        }

  defstruct [:bmi]

  field :bmi, 1, type: Proto.PatientProfile.BMI
end

defmodule Proto.PatientProfile.GetHistoryResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          social: Proto.Forms.Form.t() | nil,
          medical: Proto.Forms.Form.t() | nil,
          surgical: Proto.Forms.Form.t() | nil,
          family: Proto.Forms.Form.t() | nil,
          allergy: Proto.Forms.Form.t() | nil,
          immunization: Proto.Forms.Form.t() | nil
        }

  defstruct [:social, :medical, :surgical, :family, :allergy, :immunization]

  field :social, 1, type: Proto.Forms.Form
  field :medical, 2, type: Proto.Forms.Form
  field :surgical, 3, type: Proto.Forms.Form
  field :family, 4, type: Proto.Forms.Form
  field :allergy, 5, type: Proto.Forms.Form
  field :immunization, 6, type: Proto.Forms.Form
end

defmodule Proto.PatientProfile.UpdateHistoryRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          updated: {atom, any}
        }

  defstruct [:updated]

  oneof :updated, 0
  field :social, 1, type: Proto.Forms.Form, oneof: 0
  field :medical, 2, type: Proto.Forms.Form, oneof: 0
  field :surgical, 3, type: Proto.Forms.Form, oneof: 0
  field :family, 4, type: Proto.Forms.Form, oneof: 0
  field :allergy, 5, type: Proto.Forms.Form, oneof: 0
  field :immunization, 6, type: Proto.Forms.Form, oneof: 0
end

defmodule Proto.PatientProfile.UpdateHistoryResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          social: Proto.Forms.Form.t() | nil,
          medical: Proto.Forms.Form.t() | nil,
          surgical: Proto.Forms.Form.t() | nil,
          family: Proto.Forms.Form.t() | nil,
          allergy: Proto.Forms.Form.t() | nil,
          immunization: Proto.Forms.Form.t() | nil
        }

  defstruct [:social, :medical, :surgical, :family, :allergy, :immunization]

  field :social, 1, type: Proto.Forms.Form
  field :medical, 2, type: Proto.Forms.Form
  field :surgical, 3, type: Proto.Forms.Form
  field :family, 4, type: Proto.Forms.Form
  field :allergy, 5, type: Proto.Forms.Form
  field :immunization, 6, type: Proto.Forms.Form
end

defmodule Proto.PatientProfile.UpdateAllHistoryRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          social: Proto.Forms.Form.t() | nil,
          medical: Proto.Forms.Form.t() | nil,
          surgical: Proto.Forms.Form.t() | nil,
          family: Proto.Forms.Form.t() | nil,
          allergy: Proto.Forms.Form.t() | nil,
          immunization: Proto.Forms.Form.t() | nil
        }

  defstruct [:social, :medical, :surgical, :family, :allergy, :immunization]

  field :social, 1, type: Proto.Forms.Form
  field :medical, 2, type: Proto.Forms.Form
  field :surgical, 3, type: Proto.Forms.Form
  field :family, 4, type: Proto.Forms.Form
  field :allergy, 5, type: Proto.Forms.Form
  field :immunization, 6, type: Proto.Forms.Form
end

defmodule Proto.PatientProfile.UpdateAllHistoryResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          social: Proto.Forms.Form.t() | nil,
          medical: Proto.Forms.Form.t() | nil,
          surgical: Proto.Forms.Form.t() | nil,
          family: Proto.Forms.Form.t() | nil,
          allergy: Proto.Forms.Form.t() | nil,
          immunization: Proto.Forms.Form.t() | nil
        }

  defstruct [:social, :medical, :surgical, :family, :allergy, :immunization]

  field :social, 1, type: Proto.Forms.Form
  field :medical, 2, type: Proto.Forms.Form
  field :surgical, 3, type: Proto.Forms.Form
  field :family, 4, type: Proto.Forms.Form
  field :allergy, 5, type: Proto.Forms.Form
  field :immunization, 6, type: Proto.Forms.Form
end

defmodule Proto.PatientProfile.GetAddressResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          address: Proto.PatientProfile.Address.t() | nil
        }

  defstruct [:address]

  field :address, 1, type: Proto.PatientProfile.Address
end

defmodule Proto.PatientProfile.UpdateAddressRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          address: Proto.PatientProfile.Address.t() | nil
        }

  defstruct [:address]

  field :address, 1, type: Proto.PatientProfile.Address
end

defmodule Proto.PatientProfile.UpdateAddressResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          address: Proto.PatientProfile.Address.t() | nil
        }

  defstruct [:address]

  field :address, 1, type: Proto.PatientProfile.Address
end

defmodule Proto.PatientProfile.GetReviewOfSystemResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          review_of_system: Proto.PatientProfile.ReviewOfSystem.t() | nil
        }

  defstruct [:review_of_system]

  field :review_of_system, 1, type: Proto.PatientProfile.ReviewOfSystem
end

defmodule Proto.PatientProfile.GetInsuranceResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          insurance: Proto.PatientProfile.Insurance.t() | nil
        }

  defstruct [:insurance]

  field :insurance, 1, type: Proto.PatientProfile.Insurance
end

defmodule Proto.PatientProfile.GetReviewOfSystemHistoryResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          review_of_system_history: [Proto.PatientProfile.ReviewOfSystem.t()],
          next_token: String.t(),
          specialists: [Proto.Generics.Specialist.t()],
          patient: Proto.Generics.Patient.t() | nil
        }

  defstruct [:review_of_system_history, :next_token, :specialists, :patient]

  field :review_of_system_history, 1, repeated: true, type: Proto.PatientProfile.ReviewOfSystem
  field :next_token, 2, type: :string
  field :specialists, 3, repeated: true, type: Proto.Generics.Specialist
  field :patient, 4, type: Proto.Generics.Patient
end

defmodule Proto.PatientProfile.UpdateReviewOfSystemRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          review_of_system: Proto.Forms.Form.t() | nil
        }

  defstruct [:review_of_system]

  field :review_of_system, 1, type: Proto.Forms.Form
end

defmodule Proto.PatientProfile.UpdateReviewOfSystemResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          review_of_system: Proto.PatientProfile.ReviewOfSystem.t() | nil
        }

  defstruct [:review_of_system]

  field :review_of_system, 1, type: Proto.PatientProfile.ReviewOfSystem
end

defmodule Proto.PatientProfile.UpdateInsuranceRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          member_id: String.t(),
          provider_id: non_neg_integer
        }

  defstruct [:member_id, :provider_id]

  field :member_id, 1, type: :string
  field :provider_id, 2, type: :uint64
end

defmodule Proto.PatientProfile.UpdateInsuranceResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          insurance: Proto.PatientProfile.Insurance.t() | nil
        }

  defstruct [:insurance]

  field :insurance, 1, type: Proto.PatientProfile.Insurance
end

defmodule Proto.PatientProfile.DeleteInsuranceResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          insurance: Proto.PatientProfile.Insurance.t() | nil
        }

  defstruct [:insurance]

  field :insurance, 1, type: Proto.PatientProfile.Insurance
end

defmodule Proto.PatientProfile.GetStatusResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          onboarding_completed: boolean
        }

  defstruct [:onboarding_completed]

  field :onboarding_completed, 1, type: :bool
end

defmodule Proto.PatientProfile.GetChildrenProfilesResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          child_profiles: [Proto.PatientProfile.ChildProfile.t()]
        }

  defstruct [:child_profiles]

  field :child_profiles, 1, repeated: true, type: Proto.PatientProfile.ChildProfile
end

defmodule Proto.PatientProfile.AddChildProfileRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          basic_info_params: Proto.PatientProfile.BasicInfoParams.t() | nil
        }

  defstruct [:basic_info_params]

  field :basic_info_params, 1, type: Proto.PatientProfile.BasicInfoParams
end

defmodule Proto.PatientProfile.AddChildProfileResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          child_profile: Proto.PatientProfile.ChildProfile.t() | nil
        }

  defstruct [:child_profile]

  field :child_profile, 1, type: Proto.PatientProfile.ChildProfile
end

defmodule Proto.PatientProfile.GetRelationshipResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          related_profiles: {atom, any}
        }

  defstruct [:related_profiles]

  oneof :related_profiles, 0
  field :adult, 1, type: Proto.Generics.Patient, oneof: 0
  field :children, 2, type: Proto.PatientProfile.ChildrenList, oneof: 0
end

defmodule Proto.PatientProfile.ChildrenList do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          children: [Proto.Generics.Patient.t()]
        }

  defstruct [:children]

  field :children, 1, repeated: true, type: Proto.Generics.Patient
end

defmodule Proto.PatientProfile.ChildProfile do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          basic_info: Proto.PatientProfile.BasicInfo.t() | nil,
          auth_token: String.t(),
          patient_id: non_neg_integer
        }

  defstruct [:basic_info, :auth_token, :patient_id]

  field :basic_info, 1, type: Proto.PatientProfile.BasicInfo
  field :auth_token, 2, type: :string
  field :patient_id, 3, type: :uint64
end

defmodule Proto.PatientProfile.BasicInfo do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          title: Proto.Generics.Title.t(),
          first_name: String.t(),
          last_name: String.t(),
          birth_date: Proto.Generics.DateTime.t() | nil,
          email: String.t(),
          join_date: non_neg_integer,
          avatar_url: String.t(),
          gender: Proto.Generics.Gender.t(),
          is_insured: boolean
        }

  defstruct [
    :title,
    :first_name,
    :last_name,
    :birth_date,
    :email,
    :join_date,
    :avatar_url,
    :gender,
    :is_insured
  ]

  field :title, 1, type: Proto.Generics.Title, enum: true
  field :first_name, 2, type: :string
  field :last_name, 3, type: :string
  field :birth_date, 4, type: Proto.Generics.DateTime
  field :email, 5, type: :string
  field :join_date, 6, type: :uint64
  field :avatar_url, 7, type: :string
  field :gender, 8, type: Proto.Generics.Gender, enum: true
  field :is_insured, 9, type: :bool
end

defmodule Proto.PatientProfile.BasicInfoParams do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          title: Proto.Generics.Title.t(),
          first_name: String.t(),
          last_name: String.t(),
          birth_date: Proto.Generics.DateTime.t() | nil,
          email: String.t(),
          deprecated1: non_neg_integer,
          deprecated2: String.t(),
          avatar_resource_path: String.t(),
          gender: Proto.Generics.Gender.t()
        }

  defstruct [
    :title,
    :first_name,
    :last_name,
    :birth_date,
    :email,
    :deprecated1,
    :deprecated2,
    :avatar_resource_path,
    :gender
  ]

  field :title, 1, type: Proto.Generics.Title, enum: true
  field :first_name, 2, type: :string
  field :last_name, 3, type: :string
  field :birth_date, 4, type: Proto.Generics.DateTime
  field :email, 5, type: :string
  field :deprecated1, 6, type: :uint64
  field :deprecated2, 7, type: :string
  field :avatar_resource_path, 8, type: :string
  field :gender, 9, type: Proto.Generics.Gender, enum: true
end

defmodule Proto.PatientProfile.BMI do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          height: Proto.Generics.Height.t() | nil,
          weight: Proto.Generics.Weight.t() | nil
        }

  defstruct [:height, :weight]

  field :height, 1, type: Proto.Generics.Height
  field :weight, 2, type: Proto.Generics.Weight
end

defmodule Proto.PatientProfile.BloodPressure do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          systolic: non_neg_integer,
          diastolic: non_neg_integer,
          pulse: non_neg_integer
        }

  defstruct [:systolic, :diastolic, :pulse]

  field :systolic, 1, type: :uint32
  field :diastolic, 2, type: :uint32
  field :pulse, 3, type: :uint32
end

defmodule Proto.PatientProfile.Address do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          street: String.t(),
          home_number: String.t(),
          zip_code: String.t(),
          city: String.t(),
          country: String.t(),
          additional_numbers: String.t(),
          neighborhood: String.t()
        }

  defstruct [
    :street,
    :home_number,
    :zip_code,
    :city,
    :country,
    :additional_numbers,
    :neighborhood
  ]

  field :street, 1, type: :string
  field :home_number, 2, type: :string
  field :zip_code, 3, type: :string
  field :city, 4, type: :string
  field :country, 5, type: :string
  field :additional_numbers, 6, type: :string
  field :neighborhood, 7, type: :string
end

defmodule Proto.PatientProfile.ReviewOfSystem do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          form: Proto.Forms.Form.t() | nil,
          inserted_at: non_neg_integer,
          provided_by_specialist_id: non_neg_integer
        }

  defstruct [:form, :inserted_at, :provided_by_specialist_id]

  field :form, 1, type: Proto.Forms.Form
  field :inserted_at, 2, type: :uint64
  field :provided_by_specialist_id, 3, type: :uint64
end

defmodule Proto.PatientProfile.Insurance do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          member_id: String.t(),
          provider: Proto.Insurance.Provider.t() | nil
        }

  defstruct [:member_id, :provider]

  field :member_id, 1, type: :string
  field :provider, 2, type: Proto.Insurance.Provider
end

defmodule Proto.PatientProfile.Credentials do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer
        }

  defstruct [:id]

  field :id, 1, type: :uint64
end
