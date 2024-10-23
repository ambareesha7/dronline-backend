defmodule Proto.Generics.MedicalTitle do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t ::
          integer
          | :UNKNOWN_MEDICAL_TITLE
          | :M_D
          | :D_O
          | :PH_D
          | :D_D_S
          | :N_P
          | :P_A
          | :R_N
          | :R_D
          | :R_D_N
          | :D_P_M
          | :M_B_B_S

  field :UNKNOWN_MEDICAL_TITLE, 0

  field :M_D, 1

  field :D_O, 2

  field :PH_D, 3

  field :D_D_S, 4

  field :N_P, 5

  field :P_A, 6

  field :R_N, 7

  field :R_D, 8

  field :R_D_N, 9

  field :D_P_M, 10

  field :M_B_B_S, 11
end

defmodule Proto.Generics.Gender do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN_GENDER | :MALE | :FEMALE | :OTHER

  field :UNKNOWN_GENDER, 0

  field :MALE, 1

  field :FEMALE, 2

  field :OTHER, 3
end

defmodule Proto.Generics.Title do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN_TITLE | :MR | :MRS | :MS

  field :UNKNOWN_TITLE, 0

  field :MR, 1

  field :MRS, 2

  field :MS, 3
end

defmodule Proto.Generics.Height.Unit do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :CM

  field :CM, 0
end

defmodule Proto.Generics.Weight.Unit do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :KG

  field :KG, 0
end

defmodule Proto.Generics.Specialist.Type do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN | :GP | :NURSE | :EXTERNAL

  field :UNKNOWN, 0

  field :GP, 1

  field :NURSE, 2

  field :EXTERNAL, 3
end

defmodule Proto.Generics.Specialist.Package do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKOWN | :BASIC | :SILVER | :GOLD | :PLATINUM

  field :UNKOWN, 0

  field :BASIC, 1

  field :SILVER, 2

  field :GOLD, 3

  field :PLATINUM, 4
end

defmodule Proto.Generics.PaymentsParams.PaymentMethod do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :TELR | :EXTERNAL

  field :TELR, 0

  field :EXTERNAL, 1
end

defmodule Proto.Generics.DateTime do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          timestamp: integer
        }

  defstruct [:timestamp]

  field :timestamp, 1, type: :int64
end

defmodule Proto.Generics.Height do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          value: integer,
          unit: Proto.Generics.Height.Unit.t()
        }

  defstruct [:value, :unit]

  field :value, 1, type: :int32
  field :unit, 2, type: Proto.Generics.Height.Unit, enum: true
end

defmodule Proto.Generics.Weight do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          value: integer,
          unit: Proto.Generics.Weight.Unit.t()
        }

  defstruct [:value, :unit]

  field :value, 1, type: :int32
  field :unit, 2, type: Proto.Generics.Weight.Unit, enum: true
end

defmodule Proto.Generics.Specialist.MedicalCategory do
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

defmodule Proto.Generics.Specialist do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          title: Proto.Generics.Title.t(),
          first_name: String.t(),
          last_name: String.t(),
          avatar_url: String.t(),
          type: Proto.Generics.Specialist.Type.t(),
          package: Proto.Generics.Specialist.Package.t(),
          deprecated: [String.t()],
          medical_categories: [Proto.Generics.Specialist.MedicalCategory.t()],
          gender: Proto.Generics.Gender.t(),
          medical_title: Proto.Generics.MedicalTitle.t(),
          dha_license: String.t()
        }

  defstruct [
    :id,
    :title,
    :first_name,
    :last_name,
    :avatar_url,
    :type,
    :package,
    :deprecated,
    :medical_categories,
    :gender,
    :medical_title,
    :dha_license
  ]

  field :id, 1, type: :uint64
  field :title, 8, type: Proto.Generics.Title, enum: true
  field :first_name, 2, type: :string
  field :last_name, 3, type: :string
  field :avatar_url, 4, type: :string
  field :type, 5, type: Proto.Generics.Specialist.Type, enum: true
  field :package, 6, type: Proto.Generics.Specialist.Package, enum: true
  field :deprecated, 7, repeated: true, type: :string
  field :medical_categories, 9, repeated: true, type: Proto.Generics.Specialist.MedicalCategory
  field :gender, 10, type: Proto.Generics.Gender, enum: true
  field :medical_title, 11, type: Proto.Generics.MedicalTitle, enum: true
  field :dha_license, 12, type: :string
end

defmodule Proto.Generics.Patient.RelatedAdult do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer
        }

  defstruct [:id]

  field :id, 1, type: :uint64
end

defmodule Proto.Generics.Patient do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          first_name: String.t(),
          last_name: String.t(),
          title: Proto.Generics.Title.t(),
          birth_date: Proto.Generics.DateTime.t() | nil,
          avatar_url: String.t(),
          related_adult: Proto.Generics.Patient.RelatedAdult.t() | nil,
          gender: Proto.Generics.Gender.t(),
          is_insured: boolean,
          insurance_provider_name: String.t(),
          insurance_member_id: String.t()
        }

  defstruct [
    :id,
    :first_name,
    :last_name,
    :title,
    :birth_date,
    :avatar_url,
    :related_adult,
    :gender,
    :is_insured,
    :insurance_provider_name,
    :insurance_member_id
  ]

  field :id, 1, type: :uint64
  field :first_name, 2, type: :string
  field :last_name, 3, type: :string
  field :title, 4, type: Proto.Generics.Title, enum: true
  field :birth_date, 5, type: Proto.Generics.DateTime
  field :avatar_url, 6, type: :string
  field :related_adult, 7, type: Proto.Generics.Patient.RelatedAdult
  field :gender, 8, type: Proto.Generics.Gender, enum: true
  field :is_insured, 9, type: :bool
  field :insurance_provider_name, 10, type: :string
  field :insurance_member_id, 11, type: :string
end

defmodule Proto.Generics.Coordinates do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          lat: float | :infinity | :negative_infinity | :nan,
          lon: float | :infinity | :negative_infinity | :nan
        }

  defstruct [:lat, :lon]

  field :lat, 1, type: :float
  field :lon, 2, type: :float
end

defmodule Proto.Generics.Countries do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          countries: [Proto.Generics.Country.t()]
        }

  defstruct [:countries]

  field :countries, 1, repeated: true, type: Proto.Generics.Country
end

defmodule Proto.Generics.Country do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          dial_code: String.t()
        }

  defstruct [:id, :name, :dial_code]

  field :id, 1, type: :string
  field :name, 2, type: :string
  field :dial_code, 3, type: :string
end

defmodule Proto.Generics.PaymentsParams do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          amount: String.t(),
          currency: String.t(),
          transaction_reference: String.t(),
          payment_method: Proto.Generics.PaymentsParams.PaymentMethod.t()
        }

  defstruct [:amount, :currency, :transaction_reference, :payment_method]

  field :amount, 1, type: :string
  field :currency, 2, type: :string
  field :transaction_reference, 3, type: :string
  field :payment_method, 4, type: Proto.Generics.PaymentsParams.PaymentMethod, enum: true
end
