defmodule Proto.Payouts.GetCredentialsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          credentials: Proto.Payouts.Credentials.t() | nil
        }

  defstruct [:credentials]

  field :credentials, 1, type: Proto.Payouts.Credentials
end

defmodule Proto.Payouts.UpdateCredentialsRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          credentials: Proto.Payouts.Credentials.t() | nil
        }

  defstruct [:credentials]

  field :credentials, 1, type: Proto.Payouts.Credentials
end

defmodule Proto.Payouts.Credentials do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          iban: String.t(),
          name: String.t(),
          address: String.t(),
          bank_name: String.t(),
          bank_address: String.t(),
          bank_swift_code: String.t(),
          bank_routing_number: String.t()
        }

  defstruct [
    :iban,
    :name,
    :address,
    :bank_name,
    :bank_address,
    :bank_swift_code,
    :bank_routing_number
  ]

  field :iban, 1, type: :string
  field :name, 2, type: :string
  field :address, 3, type: :string
  field :bank_name, 4, type: :string
  field :bank_address, 5, type: :string
  field :bank_swift_code, 6, type: :string
  field :bank_routing_number, 7, type: :string
end

defmodule Proto.Payouts.GetPendingWithdrawalsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          pending_withdrawals: [Proto.Payouts.PendingWithdrawal.t()],
          patients: [Proto.Generics.Patient.t()]
        }

  defstruct [:pending_withdrawals, :patients]

  field :pending_withdrawals, 1, repeated: true, type: Proto.Payouts.PendingWithdrawal
  field :patients, 2, repeated: true, type: Proto.Generics.Patient
end

defmodule Proto.Payouts.PendingWithdrawal do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          patient_id: non_neg_integer,
          medical_category_id: non_neg_integer,
          amount: non_neg_integer,
          inserted_at: non_neg_integer,
          record_id: non_neg_integer
        }

  defstruct [:patient_id, :medical_category_id, :amount, :inserted_at, :record_id]

  field :patient_id, 1, type: :uint64
  field :medical_category_id, 2, type: :uint64
  field :amount, 3, type: :uint64
  field :inserted_at, 4, type: :uint64
  field :record_id, 5, type: :uint64
end

defmodule Proto.Payouts.GetWithdrawalsSummaryResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          withdrawals_summary: Proto.Payouts.WithdrawalsSummary.t() | nil
        }

  defstruct [:withdrawals_summary]

  field :withdrawals_summary, 1, type: Proto.Payouts.WithdrawalsSummary
end

defmodule Proto.Payouts.WithdrawalsSummary do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          incoming_withdraw: non_neg_integer,
          earned_this_month: non_neg_integer
        }

  defstruct [:incoming_withdraw, :earned_this_month]

  field :incoming_withdraw, 1, type: :uint64
  field :earned_this_month, 2, type: :uint64
end
