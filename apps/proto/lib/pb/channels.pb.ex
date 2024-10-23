defmodule Proto.Channels.GetTokenResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          token: String.t()
        }

  defstruct [:token]

  field :token, 1, type: :string
end

defmodule Proto.Channels.SocketMessage.ChannelPayload.JoinedChannel do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end

defmodule Proto.Channels.SocketMessage.ChannelPayload do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          message: {atom, any}
        }

  defstruct [:message]

  oneof :message, 0

  field :joined_channel, 1,
    type: Proto.Channels.SocketMessage.ChannelPayload.JoinedChannel,
    oneof: 0

  field :phx_reply, 2, type: :string, oneof: 0
  field :join_queue, 3, type: Proto.Calls.JoinQueue, oneof: 0
  field :leave_queue, 4, type: Proto.Calls.LeaveQueue, oneof: 0
  field :call_gp, 27, type: Proto.Calls.CallGP, oneof: 0
  field :cancel_call_to_gp, 28, type: Proto.Calls.CancelCallToGP, oneof: 0
  field :answer_call_from_nurse, 30, type: Proto.Calls.AnswerCallFromNurse, oneof: 0
  field :start_call, 7, type: Proto.Calls.StartCall, oneof: 0
  field :invite_doctor_category, 35, type: Proto.Calls.InviteDoctorCategory, oneof: 0
  field :invite_doctor, 21, type: Proto.Calls.InviteDoctor, oneof: 0

  field :cancel_doctor_category_invitation, 36,
    type: Proto.Calls.CancelDoctorCategoryInvitation,
    oneof: 0

  field :cancel_call_to_doctor, 20, type: Proto.Calls.CancelCallToDoctor, oneof: 0

  field :accept_doctor_category_invitation, 37,
    type: Proto.Calls.AcceptDoctorCategoryInvitation,
    oneof: 0

  field :answer_call_to_doctor, 18, type: Proto.Calls.AnswerCallToDoctor, oneof: 0
  field :end_call_for_all, 23, type: Proto.Calls.EndCallForAll, oneof: 0
  field :patient_location_coordinates, 25, type: Proto.Generics.Coordinates, oneof: 0
  field :patients_queue_update, 5, type: Proto.Calls.PatientsQueue, oneof: 0
  field :pending_nurse_to_gp_calls_update, 29, type: Proto.Calls.PendingNurseToGPCalls, oneof: 0

  field :doctor_category_invitations_update, 38,
    type: Proto.Calls.DoctorCategoryInvitations,
    oneof: 0

  field :queue_to_doctor_update, 17, type: Proto.Calls.QueueToDoctor, oneof: 0
  field :call_established, 8, type: Proto.Calls.CallEstablished, oneof: 0
  field :new_timeline_item, 16, type: Proto.Timeline.NewTimelineItem, oneof: 0
  field :new_timeline_item_comment, 39, type: Proto.EMR.NewTimelineItemComment, oneof: 0
  field :active_package_update, 22, type: Proto.Membership.ActivePackageUpdate, oneof: 0
  field :call_ended, 24, type: Proto.Calls.CallEnded, oneof: 0
  field :pending_dispatches_update, 26, type: Proto.Dispatches.PendingDispatchesUpdate, oneof: 0
  field :presence_state, 31, type: Proto.Presence.PresenceState, oneof: 0
  field :presence_diff, 32, type: Proto.Presence.PresenceDiff, oneof: 0
  field :pending_visits_update, 33, type: Proto.Visits.PendingVisitsUpdate, oneof: 0
  field :doctor_pending_visits_update, 34, type: Proto.Visits.DoctorPendingVisitsUpdate, oneof: 0
  field :new_notification, 40, type: Proto.Notifications.NewNotification, oneof: 0
  field :ping, 101, type: :string, oneof: 0
  field :pong, 102, type: :string, oneof: 0
end

defmodule Proto.Channels.SocketMessage do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          topic: String.t(),
          event: String.t(),
          payload: Proto.Channels.SocketMessage.ChannelPayload.t() | nil,
          ref: String.t(),
          join_ref: String.t(),
          reply_status: String.t()
        }

  defstruct [:topic, :event, :payload, :ref, :join_ref, :reply_status]

  field :topic, 1, type: :string
  field :event, 2, type: :string
  field :payload, 3, type: Proto.Channels.SocketMessage.ChannelPayload
  field :ref, 4, type: :string
  field :join_ref, 5, type: :string
  field :reply_status, 6, type: :string
end
