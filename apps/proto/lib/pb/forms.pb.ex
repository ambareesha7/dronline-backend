defmodule Proto.Forms.Form do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          fields: [Proto.Forms.FormField.t()],
          completed: boolean
        }

  defstruct [:fields, :completed]

  field :fields, 1, repeated: true, type: Proto.Forms.FormField
  field :completed, 2, type: :bool
end

defmodule Proto.Forms.FormField do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          value: {atom, any},
          uuid: String.t(),
          label: String.t()
        }

  defstruct [:value, :uuid, :label]

  oneof :value, 0
  field :uuid, 1, type: :string
  field :label, 2, type: :string
  field :select, 3, type: Proto.Forms.Select, oneof: 0
  field :multiselect, 4, type: Proto.Forms.MultiSelect, oneof: 0
  field :string, 5, type: Proto.Forms.StringField, oneof: 0
  field :integer, 6, type: Proto.Forms.IntegerField, oneof: 0
  field :month, 7, type: Proto.Forms.MonthField, oneof: 0
  field :form_fields_group, 8, type: Proto.Forms.FormFieldsGroup, oneof: 0
end

defmodule Proto.Forms.FormFieldsGroup do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          form_fields: [Proto.Forms.FormField.t()]
        }

  defstruct [:form_fields]

  field :form_fields, 1, repeated: true, type: Proto.Forms.FormField
end

defmodule Proto.Forms.Select.Option do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          uuid: String.t(),
          label: String.t(),
          subform: [Proto.Forms.FormField.t()]
        }

  defstruct [:uuid, :label, :subform]

  field :uuid, 1, type: :string
  field :label, 2, type: :string
  field :subform, 3, repeated: true, type: Proto.Forms.FormField
end

defmodule Proto.Forms.Select do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          options: [Proto.Forms.Select.Option.t()],
          choice: Proto.Forms.Select.Option.t() | nil
        }

  defstruct [:options, :choice]

  field :options, 1, repeated: true, type: Proto.Forms.Select.Option
  field :choice, 2, type: Proto.Forms.Select.Option
end

defmodule Proto.Forms.MultiSelect.Option do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          uuid: String.t(),
          label: String.t(),
          subform: [Proto.Forms.FormField.t()],
          sublabels: [String.t()],
          distinct: boolean,
          is_custom: boolean
        }

  defstruct [:uuid, :label, :subform, :sublabels, :distinct, :is_custom]

  field :uuid, 1, type: :string
  field :label, 2, type: :string
  field :subform, 3, repeated: true, type: Proto.Forms.FormField
  field :sublabels, 4, repeated: true, type: :string
  field :distinct, 5, type: :bool
  field :is_custom, 6, type: :bool
end

defmodule Proto.Forms.MultiSelect do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          options: [Proto.Forms.MultiSelect.Option.t()],
          choices: [Proto.Forms.MultiSelect.Option.t()],
          allow_custom_option: boolean
        }

  defstruct [:options, :choices, :allow_custom_option]

  field :options, 1, repeated: true, type: Proto.Forms.MultiSelect.Option
  field :choices, 2, repeated: true, type: Proto.Forms.MultiSelect.Option
  field :allow_custom_option, 3, type: :bool
end

defmodule Proto.Forms.StringField do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          value: String.t(),
          is_set: boolean
        }

  defstruct [:value, :is_set]

  field :value, 1, type: :string
  field :is_set, 2, type: :bool
end

defmodule Proto.Forms.IntegerField do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          value: integer,
          is_set: boolean
        }

  defstruct [:value, :is_set]

  field :value, 1, type: :int32
  field :is_set, 2, type: :bool
end

defmodule Proto.Forms.MonthField do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          value: integer,
          is_set: boolean
        }

  defstruct [:value, :is_set]

  field :value, 1, type: :int64
  field :is_set, 2, type: :bool
end
