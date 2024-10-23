defmodule Proto.Errors.ErrorResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          simple_error: Proto.Errors.SimpleError.t() | nil,
          form_errors: Proto.Errors.FormErrors.t() | nil
        }

  defstruct [:simple_error, :form_errors]

  field :simple_error, 1, type: Proto.Errors.SimpleError
  field :form_errors, 2, type: Proto.Errors.FormErrors
end

defmodule Proto.Errors.SimpleError do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          message: String.t()
        }

  defstruct [:message]

  field :message, 1, type: :string
end

defmodule Proto.Errors.FormErrors.FieldError do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          field: String.t(),
          message: String.t()
        }

  defstruct [:field, :message]

  field :field, 1, type: :string
  field :message, 2, type: :string
end

defmodule Proto.Errors.FormErrors do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          field_errors: [Proto.Errors.FormErrors.FieldError.t()]
        }

  defstruct [:field_errors]

  field :field_errors, 1, repeated: true, type: Proto.Errors.FormErrors.FieldError
end
