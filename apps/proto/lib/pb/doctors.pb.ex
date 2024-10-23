defmodule Proto.Doctors.PackageType do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKOWN | :BASIC | :SILVER | :GOLD | :PLATINUM

  field :UNKOWN, 0

  field :BASIC, 1

  field :SILVER, 2

  field :GOLD, 3

  field :PLATINUM, 4
end

defmodule Proto.Doctors.GetFeaturedDoctorsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          deprecated: [Proto.Doctors.FeaturedDoctor.t()],
          featured_doctors: [Proto.Generics.Specialist.t()]
        }

  defstruct [:deprecated, :featured_doctors]

  field :deprecated, 1, repeated: true, type: Proto.Doctors.FeaturedDoctor
  field :featured_doctors, 2, repeated: true, type: Proto.Generics.Specialist
end

defmodule Proto.Doctors.FeaturedDoctor do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          avatar_url: String.t(),
          first_name: String.t(),
          last_name: String.t(),
          categories: [String.t()],
          package_type: Proto.Doctors.PackageType.t()
        }

  defstruct [:id, :avatar_url, :first_name, :last_name, :categories, :package_type]

  field :id, 1, type: :uint64
  field :avatar_url, 2, type: :string
  field :first_name, 3, type: :string
  field :last_name, 4, type: :string
  field :categories, 5, repeated: true, type: :string
  field :package_type, 6, type: Proto.Doctors.PackageType, enum: true
end

defmodule Proto.Doctors.GetFavouriteProvidersResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          deprecated: [Proto.Doctors.FavouriteProvider.t()],
          favourite_providers: [Proto.Generics.Specialist.t()]
        }

  defstruct [:deprecated, :favourite_providers]

  field :deprecated, 1, repeated: true, type: Proto.Doctors.FavouriteProvider
  field :favourite_providers, 2, repeated: true, type: Proto.Generics.Specialist
end

defmodule Proto.Doctors.FavouriteProvider do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          avatar_url: String.t(),
          first_name: String.t(),
          last_name: String.t(),
          categories: [String.t()],
          package_type: Proto.Doctors.PackageType.t()
        }

  defstruct [:id, :avatar_url, :first_name, :last_name, :categories, :package_type]

  field :id, 1, type: :uint64
  field :avatar_url, 2, type: :string
  field :first_name, 3, type: :string
  field :last_name, 4, type: :string
  field :categories, 5, repeated: true, type: :string
  field :package_type, 6, type: Proto.Doctors.PackageType, enum: true
end

defmodule Proto.Doctors.GetDoctorsDetailsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          deprecated: [Proto.Doctors.DoctorDetails.t()],
          doctors_details: [Proto.Generics.Specialist.t()]
        }

  defstruct [:deprecated, :doctors_details]

  field :deprecated, 1, repeated: true, type: Proto.Doctors.DoctorDetails
  field :doctors_details, 2, repeated: true, type: Proto.Generics.Specialist
end

defmodule Proto.Doctors.DoctorDetails do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          avatar_url: String.t(),
          first_name: String.t(),
          last_name: String.t(),
          categories: [String.t()],
          package_type: Proto.Doctors.PackageType.t()
        }

  defstruct [:id, :avatar_url, :first_name, :last_name, :categories, :package_type]

  field :id, 1, type: :uint64
  field :avatar_url, 2, type: :string
  field :first_name, 3, type: :string
  field :last_name, 4, type: :string
  field :categories, 5, repeated: true, type: :string
  field :package_type, 6, type: Proto.Doctors.PackageType, enum: true
end
