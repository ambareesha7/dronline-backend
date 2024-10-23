defmodule Proto.Dispatches.DetailedDispatch.Status do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN | :OPEN | :ONGOING | :ENDED

  field :UNKNOWN, 0

  field :OPEN, 1

  field :ONGOING, 2

  field :ENDED, 3
end

defmodule Proto.Dispatches.RequestDispatchToPatientRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          patient_id: non_neg_integer,
          record_id: non_neg_integer,
          patient_location: Proto.Dispatches.PatientLocation.t() | nil
        }

  defstruct [:patient_id, :record_id, :patient_location]

  field :patient_id, 1, type: :uint64
  field :record_id, 2, type: :uint64
  field :patient_location, 3, type: Proto.Dispatches.PatientLocation
end

defmodule Proto.Dispatches.RequestDispatchToPatientResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end

defmodule Proto.Dispatches.GetPendingDispatchesResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          dispatches: [Proto.Dispatches.Dispatch.t()],
          specialists: [Proto.Generics.Specialist.t()],
          patients: [Proto.Generics.Patient.t()]
        }

  defstruct [:dispatches, :specialists, :patients]

  field :dispatches, 1, repeated: true, type: Proto.Dispatches.Dispatch
  field :specialists, 2, repeated: true, type: Proto.Generics.Specialist
  field :patients, 3, repeated: true, type: Proto.Generics.Patient
end

defmodule Proto.Dispatches.TakePendingDispatchRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end

defmodule Proto.Dispatches.TakePendingDispatchResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          dispatch: Proto.Dispatches.Dispatch.t() | nil,
          specialist: Proto.Generics.Specialist.t() | nil,
          patient: Proto.Generics.Patient.t() | nil
        }

  defstruct [:dispatch, :specialist, :patient]

  field :dispatch, 1, type: Proto.Dispatches.Dispatch
  field :specialist, 2, type: Proto.Generics.Specialist
  field :patient, 3, type: Proto.Generics.Patient
end

defmodule Proto.Dispatches.GetOngoingDispatchResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          dispatch: Proto.Dispatches.Dispatch.t() | nil,
          specialist: Proto.Generics.Specialist.t() | nil,
          patient: Proto.Generics.Patient.t() | nil
        }

  defstruct [:dispatch, :specialist, :patient]

  field :dispatch, 1, type: Proto.Dispatches.Dispatch
  field :specialist, 2, type: Proto.Generics.Specialist
  field :patient, 3, type: Proto.Generics.Patient
end

defmodule Proto.Dispatches.EndDispatchRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end

defmodule Proto.Dispatches.EndDispatchResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end

defmodule Proto.Dispatches.GetCurrentDispatchesResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          detailed_dispatches: [Proto.Dispatches.DetailedDispatch.t()],
          specialists: [Proto.Generics.Specialist.t()]
        }

  defstruct [:detailed_dispatches, :specialists]

  field :detailed_dispatches, 1, repeated: true, type: Proto.Dispatches.DetailedDispatch
  field :specialists, 2, repeated: true, type: Proto.Generics.Specialist
end

defmodule Proto.Dispatches.GetEndedDispatchesResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          detailed_dispatches: [Proto.Dispatches.DetailedDispatch.t()],
          next_token: String.t(),
          total_count: non_neg_integer,
          specialists: [Proto.Generics.Specialist.t()]
        }

  defstruct [:detailed_dispatches, :next_token, :total_count, :specialists]

  field :detailed_dispatches, 1, repeated: true, type: Proto.Dispatches.DetailedDispatch
  field :next_token, 2, type: :string
  field :total_count, 3, type: :uint32
  field :specialists, 4, repeated: true, type: Proto.Generics.Specialist
end

defmodule Proto.Dispatches.GetDispatchDetailsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          detailed_dispatch: Proto.Dispatches.DetailedDispatch.t() | nil,
          specialist: Proto.Generics.Specialist.t() | nil,
          patient: Proto.Generics.Patient.t() | nil
        }

  defstruct [:detailed_dispatch, :specialist, :patient]

  field :detailed_dispatch, 1, type: Proto.Dispatches.DetailedDispatch
  field :specialist, 2, type: Proto.Generics.Specialist
  field :patient, 3, type: Proto.Generics.Patient
end

defmodule Proto.Dispatches.PendingDispatchesUpdate do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          dispatches: [Proto.Dispatches.Dispatch.t()],
          specialists: [Proto.Generics.Specialist.t()],
          patients: [Proto.Generics.Patient.t()]
        }

  defstruct [:dispatches, :specialists, :patients]

  field :dispatches, 1, repeated: true, type: Proto.Dispatches.Dispatch
  field :specialists, 2, repeated: true, type: Proto.Generics.Specialist
  field :patients, 3, repeated: true, type: Proto.Generics.Patient
end

defmodule Proto.Dispatches.Dispatch do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          request_id: String.t(),
          requested_at: non_neg_integer,
          patient_id: non_neg_integer,
          requester_id: non_neg_integer,
          record_id: non_neg_integer,
          patient_location: Proto.Dispatches.PatientLocation.t() | nil
        }

  defstruct [
    :request_id,
    :requested_at,
    :patient_id,
    :requester_id,
    :record_id,
    :patient_location
  ]

  field :request_id, 1, type: :string
  field :requested_at, 2, type: :uint64
  field :patient_id, 3, type: :uint64
  field :requester_id, 4, type: :uint64
  field :record_id, 5, type: :uint64
  field :patient_location, 6, type: Proto.Dispatches.PatientLocation
end

defmodule Proto.Dispatches.DetailedDispatch do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          dispatch: Proto.Dispatches.Dispatch.t() | nil,
          status: Proto.Dispatches.DetailedDispatch.Status.t(),
          taken_at: Proto.Generics.DateTime.t() | nil,
          ended_at: Proto.Generics.DateTime.t() | nil,
          nurse_id: non_neg_integer
        }

  defstruct [:dispatch, :status, :taken_at, :ended_at, :nurse_id]

  field :dispatch, 1, type: Proto.Dispatches.Dispatch
  field :status, 2, type: Proto.Dispatches.DetailedDispatch.Status, enum: true
  field :taken_at, 3, type: Proto.Generics.DateTime
  field :ended_at, 4, type: Proto.Generics.DateTime
  field :nurse_id, 5, type: :uint64
end

defmodule Proto.Dispatches.PatientLocation.Address do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          country: String.t(),
          city: String.t(),
          postal_code: String.t(),
          street_name: String.t(),
          building_number: String.t(),
          district: String.t(),
          additional_numbers: String.t()
        }

  defstruct [
    :country,
    :city,
    :postal_code,
    :street_name,
    :building_number,
    :district,
    :additional_numbers
  ]

  field :country, 1, type: :string
  field :city, 2, type: :string
  field :postal_code, 3, type: :string
  field :street_name, 4, type: :string
  field :building_number, 5, type: :string
  field :district, 6, type: :string
  field :additional_numbers, 7, type: :string
end

defmodule Proto.Dispatches.PatientLocation do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          address: Proto.Dispatches.PatientLocation.Address.t() | nil
        }

  defstruct [:address]

  field :address, 1, type: Proto.Dispatches.PatientLocation.Address
end
