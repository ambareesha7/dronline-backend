defmodule Proto.Calls.AnswerCallToDoctor.Caller do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN | :GP | :NURSE

  field :UNKNOWN, 0

  field :GP, 1

  field :NURSE, 2
end

defmodule Proto.Calls.QueueToDoctor.Caller.Type do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN | :GP | :NURSE

  field :UNKNOWN, 0

  field :GP, 1

  field :NURSE, 2
end

defmodule Proto.Calls.LocalClinicResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          clinic: {atom, any}
        }

  defstruct [:clinic]

  oneof :clinic, 0
  field :local_clinic, 1, type: Proto.Calls.Clinic, oneof: 0
end

defmodule Proto.Calls.Clinic do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t(),
          logo_url: String.t()
        }

  defstruct [:name, :logo_url]

  field :name, 1, type: :string
  field :logo_url, 2, type: :string
end

defmodule Proto.Calls.GetPatientsQueueResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          patients_queue: Proto.Calls.PatientsQueue.t() | nil
        }

  defstruct [:patients_queue]

  field :patients_queue, 1, type: Proto.Calls.PatientsQueue
end

defmodule Proto.Calls.GetPendingNurseToGPCallsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          pending_calls: Proto.Calls.PendingNurseToGPCalls.t() | nil
        }

  defstruct [:pending_calls]

  field :pending_calls, 1, type: Proto.Calls.PendingNurseToGPCalls
end

defmodule Proto.Calls.GetQueueToDoctorResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          queue_to_doctor: Proto.Calls.QueueToDoctor.t() | nil
        }

  defstruct [:queue_to_doctor]

  field :queue_to_doctor, 1, type: Proto.Calls.QueueToDoctor
end

defmodule Proto.Calls.GetDoctorCategoryInvitationsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          doctor_category_invitations: Proto.Calls.DoctorCategoryInvitations.t() | nil
        }

  defstruct [:doctor_category_invitations]

  field :doctor_category_invitations, 1, type: Proto.Calls.DoctorCategoryInvitations
end

defmodule Proto.Calls.GetHPIResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          hpi: Proto.EMR.HPI.t() | nil
        }

  defstruct [:hpi]

  field :hpi, 1, type: Proto.EMR.HPI
end

defmodule Proto.Calls.UpdateHPIRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          hpi: Proto.Forms.Form.t() | nil
        }

  defstruct [:hpi]

  field :hpi, 1, type: Proto.Forms.Form
end

defmodule Proto.Calls.UpdateHPIResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          hpi: Proto.EMR.HPI.t() | nil,
          record_id: non_neg_integer
        }

  defstruct [:hpi, :record_id]

  field :hpi, 1, type: Proto.EMR.HPI
  field :record_id, 2, type: :uint64
end

defmodule Proto.Calls.GetPatientLocationCoordinatesResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          patient_location_coordinates: Proto.Generics.Coordinates.t() | nil
        }

  defstruct [:patient_location_coordinates]

  field :patient_location_coordinates, 1, type: Proto.Generics.Coordinates
end

defmodule Proto.Calls.JoinQueue do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          record_id: non_neg_integer,
          patient_location: Proto.Generics.Coordinates.t() | nil,
          payment_params: Proto.Visits.PaymentsParams.t() | nil
        }

  defstruct [:record_id, :patient_location, :payment_params]

  field :record_id, 1, type: :uint64
  field :patient_location, 2, type: Proto.Generics.Coordinates
  field :payment_params, 3, type: Proto.Visits.PaymentsParams
end

defmodule Proto.Calls.LeaveQueue do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end

defmodule Proto.Calls.CallGP do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          patient_id: non_neg_integer,
          record_id: non_neg_integer
        }

  defstruct [:patient_id, :record_id]

  field :patient_id, 1, type: :uint64
  field :record_id, 2, type: :uint64
end

defmodule Proto.Calls.CancelCallToGP do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end

defmodule Proto.Calls.AnswerCallFromNurse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          nurse_id: non_neg_integer
        }

  defstruct [:nurse_id]

  field :nurse_id, 1, type: :uint64
end

defmodule Proto.Calls.StartCall do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          caller_id: non_neg_integer
        }

  defstruct [:caller_id]

  field :caller_id, 2, type: :uint64
end

defmodule Proto.Calls.InviteDoctor do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          category_id: non_neg_integer,
          patient_id: non_neg_integer,
          record_id: non_neg_integer,
          current_session_id: String.t()
        }

  defstruct [:category_id, :patient_id, :record_id, :current_session_id]

  field :category_id, 1, type: :uint64
  field :patient_id, 2, type: :uint64
  field :record_id, 3, type: :uint64
  field :current_session_id, 4, type: :string
end

defmodule Proto.Calls.CancelCallToDoctor do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          category_id: non_neg_integer
        }

  defstruct [:category_id]

  field :category_id, 1, type: :uint64
end

defmodule Proto.Calls.AnswerCallToDoctor do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          category_id: non_neg_integer,
          caller: Proto.Calls.AnswerCallToDoctor.Caller.t(),
          caller_id: non_neg_integer,
          session_id: String.t(),
          call_id: String.t()
        }

  defstruct [:category_id, :caller, :caller_id, :session_id, :call_id]

  field :category_id, 1, type: :uint64
  field :caller, 2, type: Proto.Calls.AnswerCallToDoctor.Caller, enum: true
  field :caller_id, 3, type: :uint64
  field :session_id, 4, type: :string
  field :call_id, 5, type: :string
end

defmodule Proto.Calls.InviteDoctorCategory do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          category_id: non_neg_integer,
          patient_id: non_neg_integer,
          record_id: non_neg_integer,
          current_session_id: String.t()
        }

  defstruct [:category_id, :patient_id, :record_id, :current_session_id]

  field :category_id, 1, type: :uint64
  field :patient_id, 2, type: :uint64
  field :record_id, 3, type: :uint64
  field :current_session_id, 4, type: :string
end

defmodule Proto.Calls.CancelDoctorCategoryInvitation do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          category_id: non_neg_integer,
          call_id: String.t()
        }

  defstruct [:category_id, :call_id]

  field :category_id, 1, type: :uint64
  field :call_id, 2, type: :string
end

defmodule Proto.Calls.AcceptDoctorCategoryInvitation do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          category_id: non_neg_integer,
          call_id: String.t()
        }

  defstruct [:category_id, :call_id]

  field :category_id, 1, type: :uint64
  field :call_id, 2, type: :string
end

defmodule Proto.Calls.PatientsQueue do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          patients_queue_entries: [Proto.Calls.PatientsQueueEntry.t()],
          patients_queue_entries_v2: [Proto.Calls.PatientsQueueEntryV2.t()]
        }

  defstruct [:patients_queue_entries, :patients_queue_entries_v2]

  field :patients_queue_entries, 1, repeated: true, type: Proto.Calls.PatientsQueueEntry
  field :patients_queue_entries_v2, 2, repeated: true, type: Proto.Calls.PatientsQueueEntryV2
end

defmodule Proto.Calls.PatientsQueueEntry do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          patient: Proto.Generics.Patient.t() | nil,
          record_id: non_neg_integer
        }

  defstruct [:patient, :record_id]

  field :patient, 1, type: Proto.Generics.Patient
  field :record_id, 2, type: :uint64
end

defmodule Proto.Calls.PatientsQueueEntryV2 do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          record_id: non_neg_integer,
          patient_id: non_neg_integer,
          first_name: String.t(),
          last_name: String.t(),
          avatar_url: String.t(),
          gender: Proto.Generics.Gender.t(),
          is_signed_up: boolean
        }

  defstruct [
    :record_id,
    :patient_id,
    :first_name,
    :last_name,
    :avatar_url,
    :gender,
    :is_signed_up
  ]

  field :record_id, 1, type: :uint64
  field :patient_id, 2, type: :uint64
  field :first_name, 3, type: :string
  field :last_name, 4, type: :string
  field :avatar_url, 5, type: :string
  field :gender, 6, type: Proto.Generics.Gender, enum: true
  field :is_signed_up, 7, type: :bool
end

defmodule Proto.Calls.PendingNurseToGPCalls do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          pending_calls: [Proto.Calls.PendingNurseToGPCall.t()]
        }

  defstruct [:pending_calls]

  field :pending_calls, 1, repeated: true, type: Proto.Calls.PendingNurseToGPCall
end

defmodule Proto.Calls.PendingNurseToGPCall do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          nurse: Proto.Generics.Specialist.t() | nil,
          patient_id: non_neg_integer,
          record_id: non_neg_integer
        }

  defstruct [:nurse, :patient_id, :record_id]

  field :nurse, 1, type: Proto.Generics.Specialist
  field :patient_id, 2, type: :uint64
  field :record_id, 3, type: :uint64
end

defmodule Proto.Calls.QueueToDoctor.Caller do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          caller_id: non_neg_integer,
          type: Proto.Calls.QueueToDoctor.Caller.Type.t(),
          first_name: String.t(),
          last_name: String.t(),
          join_timestamp: non_neg_integer,
          session_id: String.t(),
          call_id: String.t(),
          patient_id: non_neg_integer,
          record_id: non_neg_integer
        }

  defstruct [
    :caller_id,
    :type,
    :first_name,
    :last_name,
    :join_timestamp,
    :session_id,
    :call_id,
    :patient_id,
    :record_id
  ]

  field :caller_id, 1, type: :uint64
  field :type, 2, type: Proto.Calls.QueueToDoctor.Caller.Type, enum: true
  field :first_name, 3, type: :string
  field :last_name, 4, type: :string
  field :join_timestamp, 5, type: :uint64
  field :session_id, 6, type: :string
  field :call_id, 7, type: :string
  field :patient_id, 8, type: :uint64
  field :record_id, 9, type: :uint64
end

defmodule Proto.Calls.QueueToDoctor do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          category_id: non_neg_integer,
          queue: [Proto.Calls.QueueToDoctor.Caller.t()]
        }

  defstruct [:category_id, :queue]

  field :category_id, 1, type: :uint64
  field :queue, 2, repeated: true, type: Proto.Calls.QueueToDoctor.Caller
end

defmodule Proto.Calls.DoctorCategoryInvitations do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          category_id: non_neg_integer,
          invitations: [Proto.Calls.DoctorCategoryInvitation.t()]
        }

  defstruct [:category_id, :invitations]

  field :category_id, 1, type: :uint64
  field :invitations, 2, repeated: true, type: Proto.Calls.DoctorCategoryInvitation
end

defmodule Proto.Calls.DoctorCategoryInvitation do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          invited_by: Proto.Generics.Specialist.t() | nil,
          call_id: String.t(),
          patient_id: non_neg_integer,
          record_id: non_neg_integer,
          sent_at: non_neg_integer
        }

  defstruct [:invited_by, :call_id, :patient_id, :record_id, :sent_at]

  field :invited_by, 1, type: Proto.Generics.Specialist
  field :call_id, 2, type: :string
  field :patient_id, 3, type: :uint64
  field :record_id, 4, type: :uint64
  field :sent_at, 5, type: :uint64
end

defmodule Proto.Calls.CallEstablished do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          token: String.t(),
          session_id: String.t(),
          patient_id: non_neg_integer,
          record_id: non_neg_integer,
          api_key: String.t(),
          call_id: String.t()
        }

  defstruct [:token, :session_id, :patient_id, :record_id, :api_key, :call_id]

  field :token, 1, type: :string
  field :session_id, 2, type: :string
  field :patient_id, 3, type: :uint64
  field :record_id, 4, type: :uint64
  field :api_key, 5, type: :string
  field :call_id, 6, type: :string
end

defmodule Proto.Calls.EndCallForAll do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end

defmodule Proto.Calls.CallEnded do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end

defmodule Proto.Calls.NursePatientCallRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          patient_id: non_neg_integer,
          record_id: non_neg_integer
        }

  defstruct [:patient_id, :record_id]

  field :patient_id, 1, type: :uint64
  field :record_id, 2, type: :uint64
end

defmodule Proto.Calls.NursePatientCallResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          patient_id: non_neg_integer,
          session_id: String.t(),
          nurse_session_token: String.t(),
          call_id: String.t(),
          api_key: String.t()
        }

  defstruct [:patient_id, :session_id, :nurse_session_token, :call_id, :api_key]

  field :patient_id, 1, type: :uint64
  field :session_id, 2, type: :string
  field :nurse_session_token, 3, type: :string
  field :call_id, 4, type: :string
  field :api_key, 5, type: :string
end

defmodule Proto.Calls.SpecialistPatientCallRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          patient_id: non_neg_integer
        }

  defstruct [:patient_id]

  field :patient_id, 1, type: :uint64
end

defmodule Proto.Calls.SpecialistPatientCallResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          patient_id: non_neg_integer,
          session_id: String.t(),
          specialist_session_token: String.t(),
          call_id: String.t(),
          api_key: String.t(),
          record_id: non_neg_integer
        }

  defstruct [:patient_id, :session_id, :specialist_session_token, :call_id, :api_key, :record_id]

  field :patient_id, 1, type: :uint64
  field :session_id, 2, type: :string
  field :specialist_session_token, 3, type: :string
  field :call_id, 4, type: :string
  field :api_key, 5, type: :string
  field :record_id, 6, type: :uint64
end

defmodule Proto.Calls.VisitCallRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          visit_id: non_neg_integer
        }

  defstruct [:visit_id]

  field :visit_id, 1, type: :uint64
end

defmodule Proto.Calls.VisitCallResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          patient_id: non_neg_integer,
          record_id: non_neg_integer,
          session_id: String.t(),
          doctor_session_token: String.t(),
          call_id: String.t(),
          api_key: String.t()
        }

  defstruct [:patient_id, :record_id, :session_id, :doctor_session_token, :call_id, :api_key]

  field :patient_id, 1, type: :uint64
  field :record_id, 6, type: :uint64
  field :session_id, 2, type: :string
  field :doctor_session_token, 3, type: :string
  field :call_id, 4, type: :string
  field :api_key, 5, type: :string
end

defmodule Proto.Calls.PendingVisitCallRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          visit_id: String.t()
        }

  defstruct [:visit_id]

  field :visit_id, 1, type: :string
end

defmodule Proto.Calls.PendingVisitCallResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          patient_id: non_neg_integer,
          record_id: non_neg_integer,
          session_id: String.t(),
          gp_session_token: String.t(),
          call_id: String.t(),
          api_key: String.t()
        }

  defstruct [:patient_id, :record_id, :session_id, :gp_session_token, :call_id, :api_key]

  field :patient_id, 1, type: :uint64
  field :record_id, 2, type: :uint64
  field :session_id, 3, type: :string
  field :gp_session_token, 4, type: :string
  field :call_id, 5, type: :string
  field :api_key, 6, type: :string
end

defmodule Proto.Calls.DoctorPendingVisitCallRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          visit_id: String.t()
        }

  defstruct [:visit_id]

  field :visit_id, 1, type: :string
end

defmodule Proto.Calls.DoctorPendingVisitCallResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          patient_id: non_neg_integer,
          record_id: non_neg_integer,
          session_id: String.t(),
          doctor_session_token: String.t(),
          call_id: String.t(),
          api_key: String.t()
        }

  defstruct [:patient_id, :record_id, :session_id, :doctor_session_token, :call_id, :api_key]

  field :patient_id, 1, type: :uint64
  field :record_id, 2, type: :uint64
  field :session_id, 3, type: :string
  field :doctor_session_token, 4, type: :string
  field :call_id, 5, type: :string
  field :api_key, 6, type: :string
end

defmodule Proto.Calls.CreateFamilyMemberInvitationRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          session_id: String.t(),
          call_id: String.t(),
          phone_number: String.t(),
          name: String.t()
        }

  defstruct [:session_id, :call_id, :phone_number, :name]

  field :session_id, 1, type: :string
  field :call_id, 2, type: :string
  field :phone_number, 3, type: :string
  field :name, 4, type: :string
end

defmodule Proto.Calls.GetFamilyMemberInvitationResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          invitation: Proto.Calls.FamilyMemberInvitation.t() | nil,
          api_key: String.t(),
          patient: Proto.Generics.Patient.t() | nil
        }

  defstruct [:invitation, :api_key, :patient]

  field :invitation, 1, type: Proto.Calls.FamilyMemberInvitation
  field :api_key, 2, type: :string
  field :patient, 3, type: Proto.Generics.Patient
end

defmodule Proto.Calls.FamilyMemberInvitation do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: String.t(),
          session_id: String.t(),
          call_id: String.t(),
          phone_number: String.t(),
          session_token: String.t(),
          name: String.t()
        }

  defstruct [:id, :session_id, :call_id, :phone_number, :session_token, :name]

  field :id, 1, type: :string
  field :session_id, 3, type: :string
  field :call_id, 4, type: :string
  field :phone_number, 5, type: :string
  field :session_token, 6, type: :string
  field :name, 7, type: :string
end
