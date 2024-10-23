defmodule Proto.EMR.Specialist.Type do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN | :GP | :NURSE | :EXTERNAL

  field :UNKNOWN, 0

  field :GP, 1

  field :NURSE, 2

  field :EXTERNAL, 4
end

defmodule Proto.EMR.Specialist.PackageType do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKOWN_PACKAGE | :BASIC | :SILVER | :GOLD | :PLATINUM

  field :UNKOWN_PACKAGE, 0

  field :BASIC, 1

  field :SILVER, 2

  field :GOLD, 3

  field :PLATINUM, 4
end

defmodule Proto.EMR.SpecialistEncounter.Type do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN_TYPE | :AUTO | :MANUAL | :VISIT | :CALL | :US_BOARD | :IN_OFFICE

  field :UNKNOWN_TYPE, 0

  field :AUTO, 1

  field :MANUAL, 2

  field :VISIT, 3

  field :CALL, 4

  field :US_BOARD, 5

  field :IN_OFFICE, 6
end

defmodule Proto.EMR.SpecialistEncounter.State do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN_STATE | :PENDING | :CANCELED | :COMPLETED

  field :UNKNOWN_STATE, 0

  field :PENDING, 1

  field :CANCELED, 2

  field :COMPLETED, 3
end

defmodule Proto.EMR.GetPatientsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          patients: [Proto.Generics.Patient.t()],
          next_token: String.t()
        }

  defstruct [:patients, :next_token]

  field :patients, 1, repeated: true, type: Proto.Generics.Patient
  field :next_token, 2, type: :string
end

defmodule Proto.EMR.GetPatientRecordsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          patient_records: [Proto.EMR.PatientRecord.t()],
          next_token: String.t(),
          specialists: [Proto.Generics.Specialist.t()]
        }

  defstruct [:patient_records, :next_token, :specialists]

  field :patient_records, 1, repeated: true, type: Proto.EMR.PatientRecord
  field :next_token, 2, type: :string
  field :specialists, 3, repeated: true, type: Proto.Generics.Specialist
end

defmodule Proto.EMR.GetPatientRecordResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          patient_record: Proto.EMR.PatientRecord.t() | nil,
          specialists: [Proto.Generics.Specialist.t()]
        }

  defstruct [:patient_record, :specialists]

  field :patient_record, 1, type: Proto.EMR.PatientRecord
  field :specialists, 2, repeated: true, type: Proto.Generics.Specialist
end

defmodule Proto.EMR.CreateMedicalRecordRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end

defmodule Proto.EMR.CreateMedicalRecordResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          patient_record: Proto.EMR.PatientRecord.t() | nil,
          specialists: [Proto.Generics.Specialist.t()]
        }

  defstruct [:patient_record, :specialists]

  field :patient_record, 1, type: Proto.EMR.PatientRecord
  field :specialists, 2, repeated: true, type: Proto.Generics.Specialist
end

defmodule Proto.EMR.InvitePatientRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          invitation: Proto.EMR.Invitation.t() | nil
        }

  defstruct [:invitation]

  field :invitation, 1, type: Proto.EMR.Invitation
end

defmodule Proto.EMR.CreatePatientRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          firebase_token: String.t()
        }

  defstruct [:firebase_token]

  field :firebase_token, 1, type: :string
end

defmodule Proto.EMR.CreatePatientResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          patient_id: non_neg_integer
        }

  defstruct [:patient_id]

  field :patient_id, 1, type: :uint64
end

defmodule Proto.EMR.AddMedicalSummaryRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          medical_summary_data: Proto.EMR.MedicalSummaryData.t() | nil,
          request_uuid: String.t(),
          conditions: [String.t()],
          procedures: [String.t()],
          skip_patient_notification: boolean
        }

  defstruct [
    :medical_summary_data,
    :request_uuid,
    :conditions,
    :procedures,
    :skip_patient_notification
  ]

  field :medical_summary_data, 1, type: Proto.EMR.MedicalSummaryData
  field :request_uuid, 2, type: :string
  field :conditions, 3, repeated: true, type: :string
  field :procedures, 4, repeated: true, type: :string
  field :skip_patient_notification, 5, type: :bool
end

defmodule Proto.EMR.AddMedicalSummaryDraftRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          medical_summary_data: Proto.EMR.MedicalSummaryData.t() | nil,
          conditions: [String.t()],
          procedures: [String.t()]
        }

  defstruct [:medical_summary_data, :conditions, :procedures]

  field :medical_summary_data, 1, type: Proto.EMR.MedicalSummaryData
  field :conditions, 2, repeated: true, type: :string
  field :procedures, 3, repeated: true, type: :string
end

defmodule Proto.EMR.GetMedicalSummariesResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          medical_summaries: [Proto.EMR.MedicalSummary.t()],
          specialists: [Proto.Generics.Specialist.t()]
        }

  defstruct [:medical_summaries, :specialists]

  field :medical_summaries, 1, repeated: true, type: Proto.EMR.MedicalSummary
  field :specialists, 2, repeated: true, type: Proto.Generics.Specialist
end

defmodule Proto.EMR.GetMedicalSummaryResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          medical_summary: Proto.EMR.MedicalSummary.t() | nil,
          specialist: Proto.Generics.Specialist.t() | nil
        }

  defstruct [:medical_summary, :specialist]

  field :medical_summary, 1, type: Proto.EMR.MedicalSummary
  field :specialist, 2, type: Proto.Generics.Specialist
end

defmodule Proto.EMR.GetRecordSpecialistsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          deprecated: [Proto.EMR.Specialist.t()],
          specialists: [Proto.Generics.Specialist.t()]
        }

  defstruct [:deprecated, :specialists]

  field :deprecated, 1, repeated: true, type: Proto.EMR.Specialist
  field :specialists, 2, repeated: true, type: Proto.Generics.Specialist
end

defmodule Proto.EMR.GetHPIResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          hpi: Proto.EMR.HPI.t() | nil
        }

  defstruct [:hpi]

  field :hpi, 1, type: Proto.EMR.HPI
end

defmodule Proto.EMR.GetHPIHistoryResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          hpis: [Proto.EMR.HPI.t()]
        }

  defstruct [:hpis]

  field :hpis, 1, repeated: true, type: Proto.EMR.HPI
end

defmodule Proto.EMR.UpdateHPIRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          hpi: Proto.Forms.Form.t() | nil
        }

  defstruct [:hpi]

  field :hpi, 1, type: Proto.Forms.Form
end

defmodule Proto.EMR.UpdateHPIResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          hpi: Proto.EMR.HPI.t() | nil
        }

  defstruct [:hpi]

  field :hpi, 1, type: Proto.EMR.HPI
end

defmodule Proto.EMR.GetRecordVisitsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          visits: [Proto.Visits.VisitDataForPatient.t()],
          next_token: String.t()
        }

  defstruct [:visits, :next_token]

  field :visits, 1, repeated: true, type: Proto.Visits.VisitDataForPatient
  field :next_token, 2, type: :string
end

defmodule Proto.EMR.GetRecordBMIEntriesResponse.BMIEntry do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          bmi: Proto.PatientProfile.BMI.t() | nil,
          inserted_at: non_neg_integer
        }

  defstruct [:bmi, :inserted_at]

  field :bmi, 1, type: Proto.PatientProfile.BMI
  field :inserted_at, 2, type: :uint64
end

defmodule Proto.EMR.GetRecordBMIEntriesResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          bmi_entries: [Proto.EMR.GetRecordBMIEntriesResponse.BMIEntry.t()],
          next_token: String.t()
        }

  defstruct [:bmi_entries, :next_token]

  field :bmi_entries, 1, repeated: true, type: Proto.EMR.GetRecordBMIEntriesResponse.BMIEntry
  field :next_token, 2, type: :string
end

defmodule Proto.EMR.GetRecordBloodPressureEntriesResponse.BloodPressureEntry do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          blood_pressure: Proto.PatientProfile.BloodPressure.t() | nil,
          inserted_at: non_neg_integer
        }

  defstruct [:blood_pressure, :inserted_at]

  field :blood_pressure, 1, type: Proto.PatientProfile.BloodPressure
  field :inserted_at, 2, type: :uint64
end

defmodule Proto.EMR.GetRecordBloodPressureEntriesResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          blood_pressure_entries: [
            Proto.EMR.GetRecordBloodPressureEntriesResponse.BloodPressureEntry.t()
          ],
          next_token: String.t()
        }

  defstruct [:blood_pressure_entries, :next_token]

  field :blood_pressure_entries, 1,
    repeated: true,
    type: Proto.EMR.GetRecordBloodPressureEntriesResponse.BloodPressureEntry

  field :next_token, 2, type: :string
end

defmodule Proto.EMR.GetRecordCallRecordingsResponse.CallRecording do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          video_url: String.t(),
          thumbnail_url: String.t(),
          session_id: String.t(),
          inserted_at: non_neg_integer
        }

  defstruct [:video_url, :thumbnail_url, :session_id, :inserted_at]

  field :video_url, 1, type: :string
  field :thumbnail_url, 2, type: :string
  field :session_id, 3, type: :string
  field :inserted_at, 4, type: :uint64
end

defmodule Proto.EMR.GetRecordCallRecordingsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          call_recordings: [Proto.EMR.GetRecordCallRecordingsResponse.CallRecording.t()],
          next_token: String.t()
        }

  defstruct [:call_recordings, :next_token]

  field :call_recordings, 1,
    repeated: true,
    type: Proto.EMR.GetRecordCallRecordingsResponse.CallRecording

  field :next_token, 2, type: :string
end

defmodule Proto.EMR.GetPendingMedicalSummaryResponse.PendingMedicalSummary do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          record_id: non_neg_integer,
          patient_id: non_neg_integer
        }

  defstruct [:record_id, :patient_id]

  field :record_id, 1, type: :uint64
  field :patient_id, 2, type: :uint64
end

defmodule Proto.EMR.GetPendingMedicalSummaryResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          pending_medical_summary:
            Proto.EMR.GetPendingMedicalSummaryResponse.PendingMedicalSummary.t() | nil,
          patient_id: non_neg_integer,
          medical_summary_draft: Proto.EMR.MedicalSummaryDraft.t() | nil
        }

  defstruct [:pending_medical_summary, :patient_id, :medical_summary_draft]

  field :pending_medical_summary, 1,
    type: Proto.EMR.GetPendingMedicalSummaryResponse.PendingMedicalSummary

  field :patient_id, 2, type: :uint64
  field :medical_summary_draft, 3, type: Proto.EMR.MedicalSummaryDraft
end

defmodule Proto.EMR.SpecialistEncountersResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          encounters: [Proto.EMR.SpecialistEncounter.t()],
          patients: [Proto.Generics.Patient.t()],
          next_token: String.t()
        }

  defstruct [:encounters, :patients, :next_token]

  field :encounters, 1, repeated: true, type: Proto.EMR.SpecialistEncounter
  field :patients, 2, repeated: true, type: Proto.Generics.Patient
  field :next_token, 3, type: :string
end

defmodule Proto.EMR.SpecialistEncounterResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          encounter: Proto.EMR.SpecialistEncounter.t() | nil,
          patient: Proto.Generics.Patient.t() | nil
        }

  defstruct [:encounter, :patient]

  field :encounter, 1, type: Proto.EMR.SpecialistEncounter
  field :patient, 2, type: Proto.Generics.Patient
end

defmodule Proto.EMR.SpecialistEncountersStatsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          scheduled: non_neg_integer,
          pending: non_neg_integer,
          completed: non_neg_integer,
          canceled: non_neg_integer
        }

  defstruct [:scheduled, :pending, :completed, :canceled]

  field :scheduled, 1, type: :uint64
  field :pending, 2, type: :uint64
  field :completed, 3, type: :uint64
  field :canceled, 4, type: :uint64
end

defmodule Proto.EMR.CreateTimelineItemCommentRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          body: String.t()
        }

  defstruct [:body]

  field :body, 1, type: :string
end

defmodule Proto.EMR.CreateTimelineItemCommentResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          timeline_item_comment: Proto.EMR.TimelineItemComment.t() | nil,
          specialist: Proto.Generics.Specialist.t() | nil,
          updated_comments_counter: non_neg_integer
        }

  defstruct [:timeline_item_comment, :specialist, :updated_comments_counter]

  field :timeline_item_comment, 1, type: Proto.EMR.TimelineItemComment
  field :specialist, 2, type: Proto.Generics.Specialist
  field :updated_comments_counter, 3, type: :uint32
end

defmodule Proto.EMR.NewTimelineItemComment do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          patient_id: non_neg_integer,
          record_id: non_neg_integer,
          timeline_item_id: String.t(),
          timeline_item_comment: Proto.EMR.TimelineItemComment.t() | nil,
          specialist: Proto.Generics.Specialist.t() | nil,
          updated_comments_counter: non_neg_integer
        }

  defstruct [
    :patient_id,
    :record_id,
    :timeline_item_id,
    :timeline_item_comment,
    :specialist,
    :updated_comments_counter
  ]

  field :patient_id, 1, type: :uint64
  field :record_id, 2, type: :uint64
  field :timeline_item_id, 3, type: :string
  field :timeline_item_comment, 4, type: Proto.EMR.TimelineItemComment
  field :specialist, 5, type: Proto.Generics.Specialist
  field :updated_comments_counter, 6, type: :uint32
end

defmodule Proto.EMR.GetTimelineItemCommentsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          timeline_item_comments: [Proto.EMR.TimelineItemComment.t()],
          specialists: [Proto.Generics.Specialist.t()],
          next_token: String.t(),
          total_comments_counter: non_neg_integer
        }

  defstruct [:timeline_item_comments, :specialists, :next_token, :total_comments_counter]

  field :timeline_item_comments, 1, repeated: true, type: Proto.EMR.TimelineItemComment
  field :specialists, 2, repeated: true, type: Proto.Generics.Specialist
  field :next_token, 3, type: :string
  field :total_comments_counter, 4, type: :uint32
end

defmodule Proto.EMR.CreateNewVitalsRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          vitals_params: Proto.EMR.VitalsParams.t() | nil
        }

  defstruct [:vitals_params]

  field :vitals_params, 1, type: Proto.EMR.VitalsParams
end

defmodule Proto.EMR.CreateNewVitalsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          vitals: Proto.EMR.Vitals.t() | nil,
          specialists: [Proto.Generics.Specialist.t()]
        }

  defstruct [:vitals, :specialists]

  field :vitals, 1, type: Proto.EMR.Vitals
  field :specialists, 2, repeated: true, type: Proto.Generics.Specialist
end

defmodule Proto.EMR.CreateOrderedTestsRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          items: [Proto.EMR.OrderedTestsParamsItem.t()]
        }

  defstruct [:items]

  field :items, 1, repeated: true, type: Proto.EMR.OrderedTestsParamsItem
end

defmodule Proto.EMR.CreateOrderedTestsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          items: [Proto.EMR.OrderedTestsItem.t()],
          specialists: [Proto.Generics.Specialist.t()]
        }

  defstruct [:items, :specialists]

  field :items, 1, repeated: true, type: Proto.EMR.OrderedTestsItem
  field :specialists, 2, repeated: true, type: Proto.Generics.Specialist
end

defmodule Proto.EMR.AssignMedicationsRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          items: [Proto.EMR.MedicationsItem.t()]
        }

  defstruct [:items]

  field :items, 1, repeated: true, type: Proto.EMR.MedicationsItem
end

defmodule Proto.EMR.GetOrderedTestsHistoryResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          bundles: [Proto.EMR.TestsBundle.t()]
        }

  defstruct [:bundles]

  field :bundles, 1, repeated: true, type: Proto.EMR.TestsBundle
end

defmodule Proto.EMR.GetMedicationsHistoryResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          bundles: [Proto.EMR.MedicationsBundle.t()]
        }

  defstruct [:bundles]

  field :bundles, 1, repeated: true, type: Proto.EMR.MedicationsBundle
end

defmodule Proto.EMR.GetVitalsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          vitals: Proto.EMR.Vitals.t() | nil,
          specialists: [Proto.Generics.Specialist.t()]
        }

  defstruct [:vitals, :specialists]

  field :vitals, 1, type: Proto.EMR.Vitals
  field :specialists, 2, repeated: true, type: Proto.Generics.Specialist
end

defmodule Proto.EMR.GetVitalsHistoryResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          vitals_history: [Proto.EMR.Vitals.t()],
          specialists: [Proto.Generics.Specialist.t()],
          next_token: String.t()
        }

  defstruct [:vitals_history, :specialists, :next_token]

  field :vitals_history, 1, repeated: true, type: Proto.EMR.Vitals
  field :specialists, 2, repeated: true, type: Proto.Generics.Specialist
  field :next_token, 3, type: :string
end

defmodule Proto.EMR.GetMedicalConditionsRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          filter: String.t()
        }

  defstruct [:filter]

  field :filter, 1, type: :string
end

defmodule Proto.EMR.GetMedicalConditionsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          conditions: [Proto.EMR.MedicalCondition.t()]
        }

  defstruct [:conditions]

  field :conditions, 1, repeated: true, type: Proto.EMR.MedicalCondition
end

defmodule Proto.EMR.GetMedicalProceduresRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          filter: String.t()
        }

  defstruct [:filter]

  field :filter, 1, type: :string
end

defmodule Proto.EMR.GetMedicalProceduresResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          procedures: [Proto.EMR.MedicalProcedure.t()]
        }

  defstruct [:procedures]

  field :procedures, 1, repeated: true, type: Proto.EMR.MedicalProcedure
end

defmodule Proto.EMR.GetMedicalMedicationsRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          filter: String.t()
        }

  defstruct [:filter]

  field :filter, 1, type: :string
end

defmodule Proto.EMR.GetMedicalMedicationsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          medications: [Proto.EMR.MedicalMedication.t()]
        }

  defstruct [:medications]

  field :medications, 1, repeated: true, type: Proto.EMR.MedicalMedication
end

defmodule Proto.EMR.GetMedicalTestsByCategoriesResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          categories: [Proto.EMR.MedicalTestsCategory.t()]
        }

  defstruct [:categories]

  field :categories, 1, repeated: true, type: Proto.EMR.MedicalTestsCategory
end

defmodule Proto.EMR.TimelineItemComment do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: String.t(),
          commented_by_specialist_id: non_neg_integer,
          body: String.t(),
          inserted_at: non_neg_integer
        }

  defstruct [:id, :commented_by_specialist_id, :body, :inserted_at]

  field :id, 1, type: :string
  field :commented_by_specialist_id, 2, type: :uint64
  field :body, 3, type: :string
  field :inserted_at, 4, type: :uint64
end

defmodule Proto.EMR.MedicalSummary do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          medical_summary_data: Proto.EMR.MedicalSummaryData.t() | nil,
          specialist_id: non_neg_integer,
          inserted_at: non_neg_integer,
          conditions: [Proto.EMR.MedicalCondition.t()],
          procedures: [Proto.EMR.MedicalProcedure.t()],
          is_draft: boolean,
          edited_at: Proto.Generics.DateTime.t() | nil
        }

  defstruct [
    :medical_summary_data,
    :specialist_id,
    :inserted_at,
    :conditions,
    :procedures,
    :is_draft,
    :edited_at
  ]

  field :medical_summary_data, 1, type: Proto.EMR.MedicalSummaryData
  field :specialist_id, 4, type: :uint64
  field :inserted_at, 3, type: :uint64
  field :conditions, 5, repeated: true, type: Proto.EMR.MedicalCondition
  field :procedures, 6, repeated: true, type: Proto.EMR.MedicalProcedure
  field :is_draft, 7, type: :bool
  field :edited_at, 8, type: Proto.Generics.DateTime
end

defmodule Proto.EMR.ShowMedicalSummaryDraftResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          medical_summary_draft: Proto.EMR.MedicalSummaryDraft.t() | nil
        }

  defstruct [:medical_summary_draft]

  field :medical_summary_draft, 1, type: Proto.EMR.MedicalSummaryDraft
end

defmodule Proto.EMR.GetLatestMedicalSummaryResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          medical_summary: Proto.EMR.MedicalSummary.t() | nil
        }

  defstruct [:medical_summary]

  field :medical_summary, 1, type: Proto.EMR.MedicalSummary
end

defmodule Proto.EMR.MedicalSummaryDraft do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          medical_summary_data: Proto.EMR.MedicalSummaryData.t() | nil,
          conditions: [Proto.EMR.MedicalCondition.t()],
          procedures: [Proto.EMR.MedicalProcedure.t()]
        }

  defstruct [:medical_summary_data, :conditions, :procedures]

  field :medical_summary_data, 2, type: Proto.EMR.MedicalSummaryData
  field :conditions, 3, repeated: true, type: Proto.EMR.MedicalCondition
  field :procedures, 4, repeated: true, type: Proto.EMR.MedicalProcedure
end

defmodule Proto.EMR.MedicalSummaryData do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          interview_summary: String.t(),
          diagnosis_category: String.t(),
          cpt_code: String.t(),
          plan: String.t(),
          impression: String.t(),
          diagnostic_testing: String.t()
        }

  defstruct [
    :interview_summary,
    :diagnosis_category,
    :cpt_code,
    :plan,
    :impression,
    :diagnostic_testing
  ]

  field :interview_summary, 1, type: :string
  field :diagnosis_category, 2, type: :string
  field :cpt_code, 3, type: :string
  field :plan, 4, type: :string
  field :impression, 5, type: :string
  field :diagnostic_testing, 6, type: :string
end

defmodule Proto.EMR.Specialist do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          type: Proto.EMR.Specialist.Type.t(),
          first_name: String.t(),
          last_name: String.t(),
          avatar_url: String.t(),
          medical_categories: [String.t()],
          package_type: Proto.EMR.Specialist.PackageType.t()
        }

  defstruct [:type, :first_name, :last_name, :avatar_url, :medical_categories, :package_type]

  field :type, 1, type: Proto.EMR.Specialist.Type, enum: true
  field :first_name, 2, type: :string
  field :last_name, 3, type: :string
  field :avatar_url, 4, type: :string
  field :medical_categories, 5, repeated: true, type: :string
  field :package_type, 6, type: Proto.EMR.Specialist.PackageType, enum: true
end

defmodule Proto.EMR.PatientRecord.Automatically do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end

defmodule Proto.EMR.PatientRecord.Specialist do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          specialist_id: non_neg_integer,
          first_name: String.t(),
          last_name: String.t(),
          avatar_url: String.t()
        }

  defstruct [:specialist_id, :first_name, :last_name, :avatar_url]

  field :specialist_id, 1, type: :uint64
  field :first_name, 2, type: :string
  field :last_name, 3, type: :string
  field :avatar_url, 4, type: :string
end

defmodule Proto.EMR.PatientRecord.Manually do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          created_by_specialist_id: non_neg_integer,
          with_specialist_id: non_neg_integer
        }

  defstruct [:created_by_specialist_id, :with_specialist_id]

  field :created_by_specialist_id, 1, type: :uint64
  field :with_specialist_id, 2, type: :uint64
end

defmodule Proto.EMR.PatientRecord.Call do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          with_specialist_id: non_neg_integer
        }

  defstruct [:with_specialist_id]

  field :with_specialist_id, 1, type: :uint64
end

defmodule Proto.EMR.PatientRecord.Scheduled do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          with_specialist_id: non_neg_integer
        }

  defstruct [:with_specialist_id]

  field :with_specialist_id, 1, type: :uint64
end

defmodule Proto.EMR.PatientRecord.UrgentCare do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          with_specialist_id: non_neg_integer
        }

  defstruct [:with_specialist_id]

  field :with_specialist_id, 1, type: :uint64
end

defmodule Proto.EMR.PatientRecord.USBoard do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          with_specialist_id: non_neg_integer,
          us_board_request_id: String.t()
        }

  defstruct [:with_specialist_id, :us_board_request_id]

  field :with_specialist_id, 1, type: :uint64
  field :us_board_request_id, 2, type: :string
end

defmodule Proto.EMR.PatientRecord do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          created: {atom, any},
          type: {atom, any},
          record_id: non_neg_integer,
          start_date: Proto.Generics.DateTime.t() | nil,
          end_date: Proto.Generics.DateTime.t() | nil,
          medical_summary_provided: boolean,
          insurance_provider_name: String.t(),
          insurance_member_id: String.t()
        }

  defstruct [
    :created,
    :type,
    :record_id,
    :start_date,
    :end_date,
    :medical_summary_provided,
    :insurance_provider_name,
    :insurance_member_id
  ]

  oneof :created, 0
  oneof :type, 1
  field :record_id, 1, type: :uint64
  field :start_date, 2, type: Proto.Generics.DateTime
  field :end_date, 3, type: Proto.Generics.DateTime
  field :medical_summary_provided, 4, type: :bool
  field :automatically, 5, type: Proto.EMR.PatientRecord.Automatically, oneof: 0
  field :by_specialist, 6, type: Proto.EMR.PatientRecord.Specialist, oneof: 0
  field :manually, 7, type: Proto.EMR.PatientRecord.Manually, oneof: 1
  field :scheduled, 8, type: Proto.EMR.PatientRecord.Scheduled, oneof: 1
  field :urgent_care, 9, type: Proto.EMR.PatientRecord.UrgentCare, oneof: 1
  field :call, 12, type: Proto.EMR.PatientRecord.Call, oneof: 1
  field :us_board, 13, type: Proto.EMR.PatientRecord.USBoard, oneof: 1
  field :insurance_provider_name, 10, type: :string
  field :insurance_member_id, 11, type: :string
end

defmodule Proto.EMR.Invitation do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          title: Proto.Generics.Title.t(),
          first_name: String.t(),
          last_name: String.t(),
          phone_number: String.t(),
          email: String.t()
        }

  defstruct [:title, :first_name, :last_name, :phone_number, :email]

  field :title, 1, type: Proto.Generics.Title, enum: true
  field :first_name, 2, type: :string
  field :last_name, 3, type: :string
  field :phone_number, 4, type: :string
  field :email, 5, type: :string
end

defmodule Proto.EMR.HPI do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          form: Proto.Forms.Form.t() | nil,
          inserted_at: Proto.Generics.DateTime.t() | nil
        }

  defstruct [:form, :inserted_at]

  field :form, 1, type: Proto.Forms.Form
  field :inserted_at, 2, type: Proto.Generics.DateTime
end

defmodule Proto.EMR.VitalsParams do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          height: Proto.Generics.Height.t() | nil,
          weight: Proto.Generics.Weight.t() | nil,
          blood_pressure_systolic: non_neg_integer,
          blood_pressure_diastolic: non_neg_integer,
          pulse: non_neg_integer,
          respiratory_rate: non_neg_integer,
          body_temperature: float | :infinity | :negative_infinity | :nan,
          physical_exam: String.t()
        }

  defstruct [
    :height,
    :weight,
    :blood_pressure_systolic,
    :blood_pressure_diastolic,
    :pulse,
    :respiratory_rate,
    :body_temperature,
    :physical_exam
  ]

  field :height, 1, type: Proto.Generics.Height
  field :weight, 2, type: Proto.Generics.Weight
  field :blood_pressure_systolic, 3, type: :uint32
  field :blood_pressure_diastolic, 4, type: :uint32
  field :pulse, 5, type: :uint32
  field :respiratory_rate, 6, type: :uint32
  field :body_temperature, 7, type: :float
  field :physical_exam, 8, type: :string
end

defmodule Proto.EMR.OrderedTestsParamsItem do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          medical_test_id: non_neg_integer,
          description: String.t()
        }

  defstruct [:medical_test_id, :description]

  field :medical_test_id, 1, type: :uint64
  field :description, 2, type: :string
end

defmodule Proto.EMR.OrderedTests do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          items: [Proto.EMR.OrderedTestsItem.t()]
        }

  defstruct [:items]

  field :items, 1, repeated: true, type: Proto.EMR.OrderedTestsItem
end

defmodule Proto.EMR.OrderedTestsItem do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          test: Proto.EMR.MedicalTest.t() | nil,
          description: String.t()
        }

  defstruct [:test, :description]

  field :test, 1, type: Proto.EMR.MedicalTest
  field :description, 2, type: :string
end

defmodule Proto.EMR.Medications do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          items: [Proto.EMR.MedicationsItem.t()]
        }

  defstruct [:items]

  field :items, 1, repeated: true, type: Proto.EMR.MedicationsItem
end

defmodule Proto.EMR.MedicationsItem do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t(),
          direction: String.t(),
          quantity: String.t(),
          refills: non_neg_integer,
          price_aed: non_neg_integer,
          medication_id: String.t()
        }

  defstruct [:name, :direction, :quantity, :refills, :price_aed, :medication_id]

  field :name, 1, type: :string
  field :direction, 2, type: :string
  field :quantity, 3, type: :string
  field :refills, 4, type: :uint32
  field :price_aed, 5, type: :uint64
  field :medication_id, 6, type: :string
end

defmodule Proto.EMR.Vitals do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          height: Proto.Generics.Height.t() | nil,
          weight: Proto.Generics.Weight.t() | nil,
          blood_pressure_systolic: non_neg_integer,
          blood_pressure_diastolic: non_neg_integer,
          pulse: non_neg_integer,
          respiratory_rate: non_neg_integer,
          body_temperature: float | :infinity | :negative_infinity | :nan,
          physical_exam: String.t(),
          record_id: non_neg_integer,
          provided_by_nurse_id: non_neg_integer,
          inserted_at: Proto.Generics.DateTime.t() | nil
        }

  defstruct [
    :height,
    :weight,
    :blood_pressure_systolic,
    :blood_pressure_diastolic,
    :pulse,
    :respiratory_rate,
    :body_temperature,
    :physical_exam,
    :record_id,
    :provided_by_nurse_id,
    :inserted_at
  ]

  field :height, 1, type: Proto.Generics.Height
  field :weight, 2, type: Proto.Generics.Weight
  field :blood_pressure_systolic, 3, type: :uint32
  field :blood_pressure_diastolic, 4, type: :uint32
  field :pulse, 5, type: :uint32
  field :respiratory_rate, 6, type: :uint32
  field :body_temperature, 7, type: :float
  field :physical_exam, 8, type: :string
  field :record_id, 9, type: :uint64
  field :provided_by_nurse_id, 10, type: :uint64
  field :inserted_at, 11, type: Proto.Generics.DateTime
end

defmodule Proto.EMR.MedicalCondition do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t()
        }

  defstruct [:id, :name]

  field :id, 1, type: :string
  field :name, 2, type: :string
end

defmodule Proto.EMR.MedicalProcedure do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t()
        }

  defstruct [:id, :name]

  field :id, 1, type: :string
  field :name, 2, type: :string
end

defmodule Proto.EMR.MedicalMedication do
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

defmodule Proto.EMR.MedicalTestsCategory do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          name: String.t(),
          tests: [Proto.EMR.MedicalTest.t()]
        }

  defstruct [:id, :name, :tests]

  field :id, 1, type: :uint64
  field :name, 2, type: :string
  field :tests, 3, repeated: true, type: Proto.EMR.MedicalTest
end

defmodule Proto.EMR.MedicalTest do
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

defmodule Proto.EMR.SpecialistEncounter do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          patient_id: non_neg_integer,
          start_time: non_neg_integer,
          end_time: non_neg_integer,
          type: Proto.EMR.SpecialistEncounter.Type.t(),
          state: Proto.EMR.SpecialistEncounter.State.t(),
          us_board_request_id: String.t()
        }

  defstruct [:id, :patient_id, :start_time, :end_time, :type, :state, :us_board_request_id]

  field :id, 1, type: :uint64
  field :patient_id, 2, type: :uint64
  field :start_time, 3, type: :uint64
  field :end_time, 4, type: :uint64
  field :type, 5, type: Proto.EMR.SpecialistEncounter.Type, enum: true
  field :state, 6, type: Proto.EMR.SpecialistEncounter.State, enum: true
  field :us_board_request_id, 7, type: :string
end

defmodule Proto.EMR.GetTestsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          bundles: [Proto.EMR.TestsBundle.t()],
          specialists: [Proto.Generics.Specialist.t()],
          patients: [Proto.Generics.Patient.t()],
          next_token: String.t()
        }

  defstruct [:bundles, :specialists, :patients, :next_token]

  field :bundles, 1, repeated: true, type: Proto.EMR.TestsBundle
  field :specialists, 2, repeated: true, type: Proto.Generics.Specialist
  field :patients, 3, repeated: true, type: Proto.Generics.Patient
  field :next_token, 4, type: :string
end

defmodule Proto.EMR.GetTestResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          bundle: Proto.EMR.TestsBundle.t() | nil,
          specialist: Proto.Generics.Specialist.t() | nil
        }

  defstruct [:bundle, :specialist]

  field :bundle, 1, type: Proto.EMR.TestsBundle
  field :specialist, 2, type: Proto.Generics.Specialist
end

defmodule Proto.EMR.TestsBundle do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          specialist_id: non_neg_integer,
          patient_id: non_neg_integer,
          tests: [Proto.EMR.Test.t()],
          inserted_at: non_neg_integer
        }

  defstruct [:specialist_id, :patient_id, :tests, :inserted_at]

  field :specialist_id, 1, type: :uint64
  field :patient_id, 2, type: :uint64
  field :tests, 3, repeated: true, type: Proto.EMR.Test
  field :inserted_at, 4, type: :uint64
end

defmodule Proto.EMR.Test do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t(),
          category_name: String.t(),
          description: String.t()
        }

  defstruct [:name, :category_name, :description]

  field :name, 1, type: :string
  field :category_name, 2, type: :string
  field :description, 3, type: :string
end

defmodule Proto.EMR.GetMedicationsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          bundles: [Proto.EMR.MedicationsBundle.t()],
          specialists: [Proto.Generics.Specialist.t()],
          patients: [Proto.Generics.Patient.t()],
          next_token: String.t()
        }

  defstruct [:bundles, :specialists, :patients, :next_token]

  field :bundles, 1, repeated: true, type: Proto.EMR.MedicationsBundle
  field :specialists, 2, repeated: true, type: Proto.Generics.Specialist
  field :patients, 3, repeated: true, type: Proto.Generics.Patient
  field :next_token, 4, type: :string
end

defmodule Proto.EMR.GetMedicationResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          bundle: Proto.EMR.MedicationsBundle.t() | nil,
          specialist: Proto.Generics.Specialist.t() | nil
        }

  defstruct [:bundle, :specialist]

  field :bundle, 1, type: Proto.EMR.MedicationsBundle
  field :specialist, 2, type: Proto.Generics.Specialist
end

defmodule Proto.EMR.SaveMedicationPayments do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          payments_params: Proto.Generics.PaymentsParams.t() | nil
        }

  defstruct [:payments_params]

  field :payments_params, 1, type: Proto.Generics.PaymentsParams
end

defmodule Proto.EMR.MedicationsBundle do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          specialist_id: non_neg_integer,
          patient_id: non_neg_integer,
          medications: [Proto.EMR.MedicationsItem.t()],
          inserted_at: non_neg_integer,
          id: non_neg_integer,
          payments_params: Proto.Generics.PaymentsParams.t() | nil
        }

  defstruct [:specialist_id, :patient_id, :medications, :inserted_at, :id, :payments_params]

  field :specialist_id, 1, type: :uint64
  field :patient_id, 2, type: :uint64
  field :medications, 3, repeated: true, type: Proto.EMR.MedicationsItem
  field :inserted_at, 4, type: :uint64
  field :id, 5, type: :uint64
  field :payments_params, 6, type: Proto.Generics.PaymentsParams
end

defmodule Proto.EMR.GetProceduresResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          bundles: [Proto.EMR.ProceduresBundle.t()],
          specialists: [Proto.Generics.Specialist.t()],
          patients: [Proto.Generics.Patient.t()],
          next_token: String.t()
        }

  defstruct [:bundles, :specialists, :patients, :next_token]

  field :bundles, 1, repeated: true, type: Proto.EMR.ProceduresBundle
  field :specialists, 2, repeated: true, type: Proto.Generics.Specialist
  field :patients, 3, repeated: true, type: Proto.Generics.Patient
  field :next_token, 4, type: :string
end

defmodule Proto.EMR.ProceduresBundle do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          specialist_id: non_neg_integer,
          patient_id: non_neg_integer,
          procedures: [String.t()],
          inserted_at: non_neg_integer
        }

  defstruct [:specialist_id, :patient_id, :procedures, :inserted_at]

  field :specialist_id, 1, type: :uint64
  field :patient_id, 2, type: :uint64
  field :procedures, 3, repeated: true, type: :string
  field :inserted_at, 4, type: :uint64
end
