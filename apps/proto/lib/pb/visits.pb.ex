defmodule Proto.Visits.VisitType do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :ONLINE | :IN_OFFICE | :US_BOARD

  field :ONLINE, 0

  field :IN_OFFICE, 1

  field :US_BOARD, 3
end

defmodule Proto.Visits.USBoardSecondOpinionRequest.Status do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t ::
          integer
          | :LANDING_FORM
          | :LANDING_BOOKING
          | :REQUESTED
          | :ASSIGNED
          | :REJECTED
          | :IN_PROGRESS
          | :OPINION_SUBMITTED
          | :CALL_SCHEDULED
          | :DONE
          | :CANCELLED
          | :LANDING_PAYMENT_PENDING

  field :LANDING_FORM, 0

  field :LANDING_BOOKING, 1

  field :REQUESTED, 2

  field :ASSIGNED, 3

  field :REJECTED, 4

  field :IN_PROGRESS, 5

  field :OPINION_SUBMITTED, 6

  field :CALL_SCHEDULED, 7

  field :DONE, 8

  field :CANCELLED, 9

  field :LANDING_PAYMENT_PENDING, 10
end

defmodule Proto.Visits.VisitDataForPatient.Status do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN | :SCHEDULED | :ONGOING | :DONE | :CANCELED

  field :UNKNOWN, 0

  field :SCHEDULED, 1

  field :ONGOING, 2

  field :DONE, 3

  field :CANCELED, 4
end

defmodule Proto.Visits.VisitDataForPatient.Type do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :ONLINE | :IN_OFFICE | :US_BOARD

  field :ONLINE, 0

  field :IN_OFFICE, 1

  field :US_BOARD, 2
end

defmodule Proto.Visits.VisitDataForSpecialist.State do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN | :PENDING | :ENDED

  field :UNKNOWN, 0

  field :PENDING, 1

  field :ENDED, 3
end

defmodule Proto.Visits.VisitDataForSpecialist.Type do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :ONLINE | :IN_OFFICE | :US_BOARD

  field :ONLINE, 0

  field :IN_OFFICE, 1

  field :US_BOARD, 2
end

defmodule Proto.Visits.PaymentsParams.PaymentMethod do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :TELR | :EXTERNAL | :US_BOARD

  field :TELR, 0

  field :EXTERNAL, 1

  field :US_BOARD, 2
end

defmodule Proto.Visits.Timeslot.VisitState do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN | :PENDING

  field :UNKNOWN, 0

  field :PENDING, 1
end

defmodule Proto.Visits.Timeslot.Free.FreeTimeslotType do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :ONLINE | :IN_OFFICE | :BOTH | :US_BOARD

  field :ONLINE, 0

  field :IN_OFFICE, 1

  field :BOTH, 2

  field :US_BOARD, 3
end

defmodule Proto.Visits.CreateTimeslotsRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          timeslot_params: [Proto.Visits.TimeslotParams.t()]
        }

  defstruct [:timeslot_params]

  field :timeslot_params, 1, repeated: true, type: Proto.Visits.TimeslotParams
end

defmodule Proto.Visits.CreateTimeslotsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end

defmodule Proto.Visits.RemoveTimeslotsRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          timeslot_params: [Proto.Visits.TimeslotParams.t()]
        }

  defstruct [:timeslot_params]

  field :timeslot_params, 1, repeated: true, type: Proto.Visits.TimeslotParams
end

defmodule Proto.Visits.RemoveTimeslotsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end

defmodule Proto.Visits.GetCalendarResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          timeslots: [Proto.Visits.Timeslot.t()]
        }

  defstruct [:timeslots]

  field :timeslots, 1, repeated: true, type: Proto.Visits.Timeslot
end

defmodule Proto.Visits.GetMedicalCategoryCalendarResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          medical_category_timeslots: [Proto.Visits.MedicalCategoryTimeslot.t()]
        }

  defstruct [:medical_category_timeslots]

  field :medical_category_timeslots, 1, repeated: true, type: Proto.Visits.MedicalCategoryTimeslot
end

defmodule Proto.Visits.GetVisitDemandAvailabilityResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          is_visit_demand_available: boolean
        }

  defstruct [:is_visit_demand_available]

  field :is_visit_demand_available, 1, type: :bool
end

defmodule Proto.Visits.GetVisitResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          visit: Proto.Visits.VisitDataForSpecialist.t() | nil,
          medical_category: Proto.Visits.MedicalCategory.t() | nil
        }

  defstruct [:visit, :medical_category]

  field :visit, 1, type: Proto.Visits.VisitDataForSpecialist
  field :medical_category, 2, type: Proto.Visits.MedicalCategory
end

defmodule Proto.Visits.GetPatientVisitResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          visit: Proto.Visits.VisitDataForPatient.t() | nil
        }

  defstruct [:visit]

  field :visit, 1, type: Proto.Visits.VisitDataForPatient
end

defmodule Proto.Visits.CreateVisitRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          timeslot_params: Proto.Visits.TimeslotParams.t() | nil,
          chosen_medical_category_id: non_neg_integer,
          payments_params: Proto.Visits.PaymentsParams.t() | nil,
          user_timezone: String.t()
        }

  defstruct [:timeslot_params, :chosen_medical_category_id, :payments_params, :user_timezone]

  field :timeslot_params, 1, type: Proto.Visits.TimeslotParams
  field :chosen_medical_category_id, 2, type: :uint64
  field :payments_params, 3, type: Proto.Visits.PaymentsParams
  field :user_timezone, 4, type: :string
end

defmodule Proto.Visits.CreateUsBoardVisitRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          timeslot_params: Proto.Visits.TimeslotParams.t() | nil,
          us_board_request_id: String.t()
        }

  defstruct [:timeslot_params, :us_board_request_id]

  field :timeslot_params, 1, type: Proto.Visits.TimeslotParams
  field :us_board_request_id, 2, type: :string
end

defmodule Proto.Visits.CreateVisitResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          record_id: non_neg_integer
        }

  defstruct [:record_id]

  field :record_id, 1, type: :uint64
end

defmodule Proto.Visits.CreateTeamMemberVisitRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          timeslot_params: Proto.Visits.TimeslotParams.t() | nil,
          chosen_medical_category_id: non_neg_integer,
          patient_id: non_neg_integer
        }

  defstruct [:timeslot_params, :chosen_medical_category_id, :patient_id]

  field :timeslot_params, 1, type: Proto.Visits.TimeslotParams
  field :chosen_medical_category_id, 2, type: :uint64
  field :patient_id, 3, type: :uint64
end

defmodule Proto.Visits.GetVisitsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          visits: [Proto.Visits.VisitDataForPatient.t()],
          next_token: String.t(),
          patients: [Proto.Generics.Patient.t()]
        }

  defstruct [:visits, :next_token, :patients]

  field :visits, 1, repeated: true, type: Proto.Visits.VisitDataForPatient
  field :next_token, 2, type: :string
  field :patients, 3, repeated: true, type: Proto.Generics.Patient
end

defmodule Proto.Visits.GetScheduledVisitsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          visits: [Proto.Visits.VisitDataForPatient.t()],
          patients: [Proto.Generics.Patient.t()],
          next_token: String.t()
        }

  defstruct [:visits, :patients, :next_token]

  field :visits, 1, repeated: true, type: Proto.Visits.VisitDataForPatient
  field :patients, 3, repeated: true, type: Proto.Generics.Patient
  field :next_token, 2, type: :string
end

defmodule Proto.Visits.GetPendingVisitsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          visits: [Proto.Visits.VisitDataForSpecialist.t()],
          patients: [Proto.Generics.Patient.t()],
          specialists: [Proto.Generics.Specialist.t()]
        }

  defstruct [:visits, :patients, :specialists]

  field :visits, 1, repeated: true, type: Proto.Visits.VisitDataForSpecialist
  field :patients, 2, repeated: true, type: Proto.Generics.Patient
  field :specialists, 3, repeated: true, type: Proto.Generics.Specialist
end

defmodule Proto.Visits.PendingVisitsUpdate do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          visits: [Proto.Visits.VisitDataForSpecialist.t()],
          patients: [Proto.Generics.Patient.t()],
          specialists: [Proto.Generics.Specialist.t()]
        }

  defstruct [:visits, :patients, :specialists]

  field :visits, 1, repeated: true, type: Proto.Visits.VisitDataForSpecialist
  field :patients, 2, repeated: true, type: Proto.Generics.Patient
  field :specialists, 3, repeated: true, type: Proto.Generics.Specialist
end

defmodule Proto.Visits.GetDoctorPendingVisitsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          visits: [Proto.Visits.VisitDataForSpecialist.t()],
          patients: [Proto.Generics.Patient.t()]
        }

  defstruct [:visits, :patients]

  field :visits, 1, repeated: true, type: Proto.Visits.VisitDataForSpecialist
  field :patients, 2, repeated: true, type: Proto.Generics.Patient
end

defmodule Proto.Visits.DoctorPendingVisitsUpdate do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          visits: [Proto.Visits.VisitDataForSpecialist.t()],
          patients: [Proto.Generics.Patient.t()]
        }

  defstruct [:visits, :patients]

  field :visits, 1, repeated: true, type: Proto.Visits.VisitDataForSpecialist
  field :patients, 2, repeated: true, type: Proto.Generics.Patient
end

defmodule Proto.Visits.GetEndedVisitsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          visits: [Proto.Visits.VisitDataForSpecialist.t()],
          patients: [Proto.Generics.Patient.t()],
          next_token: String.t()
        }

  defstruct [:visits, :patients, :next_token]

  field :visits, 1, repeated: true, type: Proto.Visits.VisitDataForSpecialist
  field :patients, 2, repeated: true, type: Proto.Generics.Patient
  field :next_token, 3, type: :string
end

defmodule Proto.Visits.USBoardSecondOpinionRequestsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          us_board_second_opinion_requests: [Proto.Visits.USBoardSecondOpinionRequest.t()]
        }

  defstruct [:us_board_second_opinion_requests]

  field :us_board_second_opinion_requests, 1,
    repeated: true,
    type: Proto.Visits.USBoardSecondOpinionRequest
end

defmodule Proto.Visits.USBoardSecondOpinionRequestResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          us_board_second_opinion_request: Proto.Visits.USBoardSecondOpinionRequest.t() | nil
        }

  defstruct [:us_board_second_opinion_request]

  field :us_board_second_opinion_request, 1, type: Proto.Visits.USBoardSecondOpinionRequest
end

defmodule Proto.Visits.USBoardSecondOpinionRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: String.t(),
          specialist_id: non_neg_integer,
          patient_id: non_neg_integer,
          visit_id: String.t(),
          inserted_at: Proto.Generics.DateTime.t() | nil,
          patient_description: String.t(),
          specialist_opinion: String.t(),
          patient_email: String.t(),
          status: Proto.Visits.USBoardSecondOpinionRequest.Status.t(),
          files: [Proto.Visits.USBoardFilesToDownload.t()],
          payments_params: Proto.Visits.PaymentsParams.t() | nil,
          specialists_history: [Proto.Visits.SpecialistHistory.t()]
        }

  defstruct [
    :id,
    :specialist_id,
    :patient_id,
    :visit_id,
    :inserted_at,
    :patient_description,
    :specialist_opinion,
    :patient_email,
    :status,
    :files,
    :payments_params,
    :specialists_history
  ]

  field :id, 1, type: :string
  field :specialist_id, 2, type: :uint64
  field :patient_id, 3, type: :uint64
  field :visit_id, 4, type: :string
  field :inserted_at, 5, type: Proto.Generics.DateTime
  field :patient_description, 6, type: :string
  field :specialist_opinion, 7, type: :string
  field :patient_email, 8, type: :string
  field :status, 9, type: Proto.Visits.USBoardSecondOpinionRequest.Status, enum: true
  field :files, 10, repeated: true, type: Proto.Visits.USBoardFilesToDownload
  field :payments_params, 11, type: Proto.Visits.PaymentsParams
  field :specialists_history, 12, repeated: true, type: Proto.Visits.SpecialistHistory
end

defmodule Proto.Visits.RequestUSBoardSecondOpinionRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          patient_description: String.t(),
          patient_email: String.t(),
          payments_params: Proto.Visits.PaymentsParams.t() | nil,
          files: [Proto.Visits.USBoardFiles.t()]
        }

  defstruct [:patient_description, :patient_email, :payments_params, :files]

  field :patient_description, 1, type: :string
  field :patient_email, 2, type: :string
  field :payments_params, 3, type: Proto.Visits.PaymentsParams
  field :files, 4, repeated: true, type: Proto.Visits.USBoardFiles
end

defmodule Proto.Visits.LandingRequestUSBoardSecondOpinionRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          patient_description: String.t(),
          patient_email: String.t(),
          files: [Proto.Visits.USBoardFiles.t()],
          phone_number: String.t(),
          first_name: String.t(),
          last_name: String.t()
        }

  defstruct [:patient_description, :patient_email, :files, :phone_number, :first_name, :last_name]

  field :patient_description, 1, type: :string
  field :patient_email, 2, type: :string
  field :files, 3, repeated: true, type: Proto.Visits.USBoardFiles
  field :phone_number, 4, type: :string
  field :first_name, 5, type: :string
  field :last_name, 6, type: :string
end

defmodule Proto.Visits.LandingUrgentHelpRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          phone_number: String.t(),
          email: String.t(),
          first_name: String.t(),
          last_name: String.t()
        }

  defstruct [:phone_number, :email, :first_name, :last_name]

  field :phone_number, 1, type: :string
  field :email, 2, type: :string
  field :first_name, 3, type: :string
  field :last_name, 4, type: :string
end

defmodule Proto.Visits.LandingUrgentHelpResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          patient_id: non_neg_integer,
          urgent_help_request_id: String.t(),
          payment_url: String.t(),
          auth_token: String.t()
        }

  defstruct [:patient_id, :urgent_help_request_id, :payment_url, :auth_token]

  field :patient_id, 1, type: :uint64
  field :urgent_help_request_id, 2, type: :string
  field :payment_url, 3, type: :string
  field :auth_token, 4, type: :string
end

defmodule Proto.Visits.LandingRequestUSBoardSecondOpinionResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          payment_url: String.t(),
          second_opinion_request_id: String.t()
        }

  defstruct [:payment_url, :second_opinion_request_id]

  field :payment_url, 1, type: :string
  field :second_opinion_request_id, 2, type: :string
end

defmodule Proto.Visits.LandingConfirmUSBoardSecondOpinionRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          transaction_reference: String.t(),
          second_opinion_request_id: String.t()
        }

  defstruct [:transaction_reference, :second_opinion_request_id]

  field :transaction_reference, 1, type: :string
  field :second_opinion_request_id, 2, type: :string
end

defmodule Proto.Visits.LandingUSBoardContactFormRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          patient_email: String.t(),
          patient_description: String.t()
        }

  defstruct [:patient_email, :patient_description]

  field :patient_email, 1, type: :string
  field :patient_description, 2, type: :string
end

defmodule Proto.Visits.RequestUSBoardSecondOpinionResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: String.t()
        }

  defstruct [:id]

  field :id, 1, type: :string
end

defmodule Proto.Visits.USBoardFilesToDownload do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          download_url: String.t()
        }

  defstruct [:download_url]

  field :download_url, 1, type: :string
end

defmodule Proto.Visits.USBoardFiles do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          path: String.t()
        }

  defstruct [:path]

  field :path, 1, type: :string
end

defmodule Proto.Visits.GetSpecialistsUSBoardOpinions do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          requested_opinions: [Proto.Visits.SpecialistsUSBoardOpinion.t()]
        }

  defstruct [:requested_opinions]

  field :requested_opinions, 1, repeated: true, type: Proto.Visits.SpecialistsUSBoardOpinion
end

defmodule Proto.Visits.SpecialistsUSBoardOpinion do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: String.t(),
          patient: Proto.Visits.USBoardPatient.t() | nil,
          status: Proto.Visits.USBoardSecondOpinionRequest.Status.t(),
          accepted_at: Proto.Generics.DateTime.t() | nil,
          rejected_at: Proto.Generics.DateTime.t() | nil,
          assigned_at: Proto.Generics.DateTime.t() | nil
        }

  defstruct [:id, :patient, :status, :accepted_at, :rejected_at, :assigned_at]

  field :id, 1, type: :string
  field :patient, 2, type: Proto.Visits.USBoardPatient
  field :status, 3, type: Proto.Visits.USBoardSecondOpinionRequest.Status, enum: true
  field :accepted_at, 4, type: Proto.Generics.DateTime
  field :rejected_at, 5, type: Proto.Generics.DateTime
  field :assigned_at, 6, type: Proto.Generics.DateTime
end

defmodule Proto.Visits.USBoardPatient do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          first_name: String.t(),
          last_name: String.t(),
          email: String.t(),
          gender: Proto.Generics.Gender.t(),
          birth_date: Proto.Generics.DateTime.t() | nil,
          avatar_url: String.t()
        }

  defstruct [:first_name, :last_name, :email, :gender, :birth_date, :avatar_url]

  field :first_name, 1, type: :string
  field :last_name, 2, type: :string
  field :email, 3, type: :string
  field :gender, 4, type: Proto.Generics.Gender, enum: true
  field :birth_date, 5, type: Proto.Generics.DateTime
  field :avatar_url, 6, type: :string
end

defmodule Proto.Visits.USBoardRequestDetails do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          files: [Proto.Visits.USBoardFilesToDownload.t()],
          patient_description: String.t(),
          specialist_opinion: String.t(),
          id: String.t(),
          status: Proto.Visits.USBoardSecondOpinionRequest.Status.t(),
          inserted_at: Proto.Generics.DateTime.t() | nil
        }

  defstruct [:files, :patient_description, :specialist_opinion, :id, :status, :inserted_at]

  field :files, 1, repeated: true, type: Proto.Visits.USBoardFilesToDownload
  field :patient_description, 2, type: :string
  field :specialist_opinion, 3, type: :string
  field :id, 4, type: :string
  field :status, 5, type: Proto.Visits.USBoardSecondOpinionRequest.Status, enum: true
  field :inserted_at, 6, type: Proto.Generics.DateTime
end

defmodule Proto.Visits.PostUSBoardSpecialistOpinion do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          specialist_opinion: String.t()
        }

  defstruct [:specialist_opinion]

  field :specialist_opinion, 1, type: :string
end

defmodule Proto.Visits.VisitDataForPatient do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          status: Proto.Visits.VisitDataForPatient.Status.t(),
          start_time: non_neg_integer,
          specialist_id: non_neg_integer,
          patient_id: non_neg_integer,
          record_id: non_neg_integer,
          id: String.t(),
          payments_params: Proto.Visits.PaymentsParams.t() | nil,
          medical_category: Proto.Visits.MedicalCategory.t() | nil,
          visit_type: Proto.Visits.VisitDataForPatient.Type.t(),
          deprecated1: non_neg_integer
        }

  defstruct [
    :status,
    :start_time,
    :specialist_id,
    :patient_id,
    :record_id,
    :id,
    :payments_params,
    :medical_category,
    :visit_type,
    :deprecated1
  ]

  field :status, 1, type: Proto.Visits.VisitDataForPatient.Status, enum: true
  field :start_time, 2, type: :uint64
  field :specialist_id, 3, type: :uint64
  field :patient_id, 5, type: :uint64
  field :record_id, 6, type: :uint64
  field :id, 7, type: :string
  field :payments_params, 8, type: Proto.Visits.PaymentsParams
  field :medical_category, 9, type: Proto.Visits.MedicalCategory
  field :visit_type, 10, type: Proto.Visits.VisitDataForPatient.Type, enum: true
  field :deprecated1, 4, type: :uint64
end

defmodule Proto.Visits.VisitDataForSpecialist do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: String.t(),
          patient_id: non_neg_integer,
          record_id: non_neg_integer,
          scheduled_with: non_neg_integer,
          starts_at: non_neg_integer,
          scheduled_at: non_neg_integer,
          chosen_medical_category_id: non_neg_integer,
          state: Proto.Visits.VisitDataForSpecialist.State.t(),
          type: Proto.Visits.VisitDataForSpecialist.Type.t()
        }

  defstruct [
    :id,
    :patient_id,
    :record_id,
    :scheduled_with,
    :starts_at,
    :scheduled_at,
    :chosen_medical_category_id,
    :state,
    :type
  ]

  field :id, 1, type: :string
  field :patient_id, 2, type: :uint64
  field :record_id, 3, type: :uint64
  field :scheduled_with, 4, type: :uint64
  field :starts_at, 5, type: :uint64
  field :scheduled_at, 6, type: :uint64
  field :chosen_medical_category_id, 7, type: :uint64
  field :state, 8, type: Proto.Visits.VisitDataForSpecialist.State, enum: true
  field :type, 9, type: Proto.Visits.VisitDataForSpecialist.Type, enum: true
end

defmodule Proto.Visits.TimeslotParams do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          start_time: non_neg_integer,
          visit_type: Proto.Visits.Timeslot.Free.FreeTimeslotType.t()
        }

  defstruct [:start_time, :visit_type]

  field :start_time, 1, type: :uint64
  field :visit_type, 2, type: Proto.Visits.Timeslot.Free.FreeTimeslotType, enum: true
end

defmodule Proto.Visits.PaymentsParams do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          amount: String.t(),
          currency: String.t(),
          transaction_reference: String.t(),
          payment_method: Proto.Visits.PaymentsParams.PaymentMethod.t()
        }

  defstruct [:amount, :currency, :transaction_reference, :payment_method]

  field :amount, 1, type: :string
  field :currency, 2, type: :string
  field :transaction_reference, 3, type: :string
  field :payment_method, 4, type: Proto.Visits.PaymentsParams.PaymentMethod, enum: true
end

defmodule Proto.Visits.SpecialistHistory do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          specialist_id: non_neg_integer,
          rejected_at: Proto.Generics.DateTime.t() | nil,
          accepted_at: Proto.Generics.DateTime.t() | nil,
          specialist_first_name: String.t(),
          specialist_last_name: String.t(),
          assigned_at: Proto.Generics.DateTime.t() | nil
        }

  defstruct [
    :specialist_id,
    :rejected_at,
    :accepted_at,
    :specialist_first_name,
    :specialist_last_name,
    :assigned_at
  ]

  field :specialist_id, 1, type: :uint64
  field :rejected_at, 2, type: Proto.Generics.DateTime
  field :accepted_at, 3, type: Proto.Generics.DateTime
  field :specialist_first_name, 4, type: :string
  field :specialist_last_name, 5, type: :string
  field :assigned_at, 6, type: Proto.Generics.DateTime
end

defmodule Proto.Visits.GetPaymentForVisit do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          amount: String.t(),
          currency: String.t(),
          record_id: non_neg_integer,
          payment_method: String.t()
        }

  defstruct [:amount, :currency, :record_id, :payment_method]

  field :amount, 1, type: :string
  field :currency, 2, type: :string
  field :record_id, 3, type: :uint64
  field :payment_method, 4, type: :string
end

defmodule Proto.Visits.Timeslot.Free do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          visit_type: Proto.Visits.Timeslot.Free.FreeTimeslotType.t()
        }

  defstruct [:visit_type]

  field :visit_type, 1, type: Proto.Visits.Timeslot.Free.FreeTimeslotType, enum: true
end

defmodule Proto.Visits.Timeslot.Taken do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          patient_id: non_neg_integer,
          record_id: non_neg_integer,
          visit_state: Proto.Visits.Timeslot.VisitState.t(),
          visit_id: String.t(),
          visit_type: Proto.Visits.VisitType.t()
        }

  defstruct [:patient_id, :record_id, :visit_state, :visit_id, :visit_type]

  field :patient_id, 1, type: :uint64
  field :record_id, 2, type: :uint64
  field :visit_state, 3, type: Proto.Visits.Timeslot.VisitState, enum: true
  field :visit_id, 4, type: :string
  field :visit_type, 5, type: Proto.Visits.VisitType, enum: true
end

defmodule Proto.Visits.Timeslot do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          status: {atom, any},
          start_time: non_neg_integer
        }

  defstruct [:status, :start_time]

  oneof :status, 0
  field :start_time, 1, type: :uint64
  field :free, 3, type: Proto.Visits.Timeslot.Free, oneof: 0
  field :taken, 4, type: Proto.Visits.Timeslot.Taken, oneof: 0
end

defmodule Proto.Visits.MedicalCategoryTimeslot do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          start_time: non_neg_integer,
          available_specialist_ids: [non_neg_integer]
        }

  defstruct [:start_time, :available_specialist_ids]

  field :start_time, 1, type: :uint64
  field :available_specialist_ids, 2, repeated: true, type: :uint64
end

defmodule Proto.Visits.MedicalCategory do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          name: String.t(),
          parent_category_id: non_neg_integer
        }

  defstruct [:id, :name, :parent_category_id]

  field :id, 1, type: :uint64
  field :name, 2, type: :string
  field :parent_category_id, 3, type: :uint64
end

defmodule Proto.Visits.DaySchedule do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          specialist_id: non_neg_integer,
          date: Proto.Generics.DateTime.t() | nil,
          free_timeslots: [Proto.Visits.Timeslot.t()],
          taken_timeslots: [Proto.Visits.Timeslot.t()],
          free_timeslots_count: non_neg_integer,
          taken_timeslots_count: non_neg_integer
        }

  defstruct [
    :id,
    :specialist_id,
    :date,
    :free_timeslots,
    :taken_timeslots,
    :free_timeslots_count,
    :taken_timeslots_count
  ]

  field :id, 1, type: :uint64
  field :specialist_id, 2, type: :uint64
  field :date, 3, type: Proto.Generics.DateTime
  field :free_timeslots, 4, repeated: true, type: Proto.Visits.Timeslot
  field :taken_timeslots, 5, repeated: true, type: Proto.Visits.Timeslot
  field :free_timeslots_count, 6, type: :uint64
  field :taken_timeslots_count, 7, type: :uint64
end

defmodule Proto.Visits.GetUploadedDocuments do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          document_urls: [String.t()]
        }

  defstruct [:document_urls]

  field :document_urls, 1, repeated: true, type: :string
end

defmodule Proto.Visits.MoveVisitToCanceledResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          refund: boolean
        }

  defstruct [:refund]

  field :refund, 1, type: :bool
end
