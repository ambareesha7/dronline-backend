defmodule Proto.Vitals.VitalsEntry do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          bmi: Proto.PatientProfile.BMI.t() | nil,
          blood_pressure: Proto.PatientProfile.BloodPressure.t() | nil,
          ekg: Proto.Vitals.EKG.t() | nil
        }

  defstruct [:id, :bmi, :blood_pressure, :ekg]

  field :id, 1, type: :uint64
  field :bmi, 2, type: Proto.PatientProfile.BMI
  field :blood_pressure, 3, type: Proto.PatientProfile.BloodPressure
  field :ekg, 4, type: Proto.Vitals.EKG
end

defmodule Proto.Vitals.EKG do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          file_url: String.t()
        }

  defstruct [:file_url]

  field :file_url, 1, type: :string
end
