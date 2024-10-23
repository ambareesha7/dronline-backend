defmodule Proto.Teams.Role do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN_TYPE | :MEMBER | :ADMIN | :EXTERNAL

  field :UNKNOWN_TYPE, 0

  field :MEMBER, 1

  field :ADMIN, 2

  field :EXTERNAL, 3
end

defmodule Proto.Teams.AddMember.Type do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :UNKNOWN_TYPE | :GP | :NURSE | :EXTERNAL

  field :UNKNOWN_TYPE, 0

  field :GP, 1

  field :NURSE, 2

  field :EXTERNAL, 3
end

defmodule Proto.Teams.MyTeam do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          team_id: non_neg_integer,
          location: Proto.Generics.Coordinates.t() | nil,
          formatted_address: String.t(),
          is_current_user_admin: boolean,
          is_current_user_owner: boolean,
          name: String.t(),
          logo_url: String.t()
        }

  defstruct [
    :team_id,
    :location,
    :formatted_address,
    :is_current_user_admin,
    :is_current_user_owner,
    :name,
    :logo_url
  ]

  field :team_id, 1, type: :uint64
  field :location, 2, type: Proto.Generics.Coordinates
  field :formatted_address, 3, type: :string
  field :is_current_user_admin, 4, type: :bool
  field :is_current_user_owner, 5, type: :bool
  field :name, 6, type: :string
  field :logo_url, 7, type: :string
end

defmodule Proto.Teams.TeamInvitations do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          invitations: [Proto.Teams.TeamInvitation.t()]
        }

  defstruct [:invitations]

  field :invitations, 1, repeated: true, type: Proto.Teams.TeamInvitation
end

defmodule Proto.Teams.TeamInvitation do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          team_id: non_neg_integer,
          owner_profile: Proto.Generics.Specialist.t() | nil
        }

  defstruct [:team_id, :owner_profile]

  field :team_id, 1, type: :uint64
  field :owner_profile, 2, type: Proto.Generics.Specialist
end

defmodule Proto.Teams.TeamMember do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          profile: Proto.Generics.Specialist.t() | nil,
          member_role: Proto.Teams.Role.t(),
          encounters_stats: Proto.Teams.TeamEncountersStatsResponse.t() | nil
        }

  defstruct [:profile, :member_role, :encounters_stats]

  field :profile, 1, type: Proto.Generics.Specialist
  field :member_role, 2, type: Proto.Teams.Role, enum: true
  field :encounters_stats, 3, type: Proto.Teams.TeamEncountersStatsResponse
end

defmodule Proto.Teams.TeamMembersResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          team_members: [Proto.Teams.TeamMember.t()]
        }

  defstruct [:team_members]

  field :team_members, 1, repeated: true, type: Proto.Teams.TeamMember
end

defmodule Proto.Teams.AddMember do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          specialist_email: String.t(),
          account_type: Proto.Teams.AddMember.Type.t()
        }

  defstruct [:specialist_email, :account_type]

  field :specialist_email, 1, type: :string
  field :account_type, 2, type: Proto.Teams.AddMember.Type, enum: true
end

defmodule Proto.Teams.SetRole do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          new_role: Proto.Teams.Role.t()
        }

  defstruct [:new_role]

  field :new_role, 1, type: Proto.Teams.Role, enum: true
end

defmodule Proto.Teams.SetTeamLocation do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          location: Proto.Generics.Coordinates.t() | nil,
          formatted_address: String.t()
        }

  defstruct [:location, :formatted_address]

  field :location, 1, type: Proto.Generics.Coordinates
  field :formatted_address, 2, type: :string
end

defmodule Proto.Teams.SetBranding do
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

defmodule Proto.Teams.TeamEncountersStatsResponse do
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

defmodule Proto.Teams.TeamUrgentCareStatsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          total: non_neg_integer
        }

  defstruct [:total]

  field :total, 1, type: :uint64
end
